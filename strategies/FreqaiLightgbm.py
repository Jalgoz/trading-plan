"""
Estrategia: FreqAI con LightGBM Classifier (Fase 3 — Con ML)

Lógica:
- Usa FreqAI para entrenar un modelo LightGBM que predice dirección del precio
- Features: indicadores técnicos (RSI, EMA, Bollinger, volumen, retornos)
- Target: si el precio sube o baja más de un umbral en las próximas N velas
- Re-entrenamiento automático cada X velas para adaptarse al mercado

Configuración necesaria en config.json:
- Agregar bloque "freqai" (ver config-backtest.json con FreqAI habilitado)

IMPORTANTE: Requiere completar Fase 2 (ML) antes de modificar esta estrategia.
"""

import logging

import numpy as np
from pandas import DataFrame

from freqtrade.strategy import IStrategy, IntParameter, DecimalParameter


logger = logging.getLogger(__name__)


class FreqaiLightgbm(IStrategy):
    """
    Estrategia que usa FreqAI con LightGBM para generar señales de trading.
    El modelo predice si el precio subirá o bajará en las próximas velas.
    """

    INTERFACE_VERSION = 3

    timeframe = "1h"

    # Stoploss más amplio — el modelo ML debería manejar las salidas
    stoploss = -0.07

    trailing_stop = True
    trailing_stop_positive = 0.01
    trailing_stop_positive_offset = 0.03
    trailing_only_offset_is_reached = True

    minimal_roi = {
        "0": 0.10,
        "120": 0.05,
        "240": 0.02,
    }

    process_only_new_candles = True
    use_exit_signal = True
    startup_candle_count: int = 100

    # Umbral de confianza del modelo para actuar
    # Solo compra si el modelo tiene >60% de probabilidad de subida
    entry_threshold = DecimalParameter(0.55, 0.75, default=0.60, space="buy", optimize=True)
    exit_threshold = DecimalParameter(0.55, 0.75, default=0.60, space="sell", optimize=True)

    def feature_engineering_expand_all(
        self, dataframe: DataFrame, period: int, metadata: dict, **kwargs
    ) -> DataFrame:
        """
        Features que se calculan para MÚLTIPLES periodos automáticamente.
        FreqAI los expandirá con los periodos definidos en config
        (ej: indicator_periods_candles: [10, 20, 50]).

        Cada feature aquí se duplicará para cada periodo: rsi_10, rsi_20, rsi_50, etc.
        """
        # RSI — Relative Strength Index
        dataframe["%-rsi-period"] = (
            dataframe["close"]
            .rolling(period)
            .apply(lambda x: 100 - (100 / (1 + (x.diff().clip(lower=0).mean() /
                                                  x.diff().clip(upper=0).abs().mean()))))
        )

        # Retorno porcentual en N periodos
        dataframe["%-pct-change"] = dataframe["close"].pct_change(periods=period)

        # Ratio close/EMA — mide si el precio está arriba o abajo de la EMA
        dataframe["%-close-ema-ratio"] = (
            dataframe["close"] / dataframe["close"].rolling(period).mean()
        )

        # Volatilidad (desviación estándar de retornos)
        dataframe["%-volatility"] = dataframe["close"].pct_change().rolling(period).std()

        # Ratio de volumen vs promedio
        dataframe["%-volume-ratio"] = (
            dataframe["volume"] / dataframe["volume"].rolling(period).mean()
        )

        # Rango de la vela normalizado (high-low)/close
        dataframe["%-candle-range"] = (
            (dataframe["high"] - dataframe["low"]) / dataframe["close"]
        ).rolling(period).mean()

        return dataframe

    def feature_engineering_expand_basic(
        self, dataframe: DataFrame, metadata: dict, **kwargs
    ) -> DataFrame:
        """
        Features que se calculan una sola vez (sin expansión por periodo).
        Útil para features que no tienen sentido con múltiples periodos.
        """
        # Hora del día (los mercados crypto tienen patrones horarios)
        dataframe["%-hour"] = dataframe["date"].dt.hour

        # Día de la semana
        dataframe["%-day-of-week"] = dataframe["date"].dt.dayofweek

        # Retorno de la vela actual
        dataframe["%-raw-return"] = dataframe["close"].pct_change()

        # ¿La vela es verde o roja?
        dataframe["%-is-green"] = (dataframe["close"] > dataframe["open"]).astype(int)

        # Ratio volumen actual vs anterior
        dataframe["%-volume-change"] = dataframe["volume"].pct_change()

        return dataframe

    def feature_engineering_standard(
        self, dataframe: DataFrame, metadata: dict, **kwargs
    ) -> DataFrame:
        """
        Features estándar requeridos por FreqAI. No modificar los nombres con &.
        """
        # Target: dirección del precio en las próximas 4 velas
        # 1 = sube más de 1%, 0 = no sube
        dataframe["&-target"] = (
            (dataframe["close"].shift(-4) / dataframe["close"] - 1) > 0.01
        ).astype(int)

        return dataframe

    def set_freqai_targets(self, dataframe: DataFrame, metadata: dict, **kwargs) -> DataFrame:
        """
        Alternativa moderna para definir targets en FreqAI.
        Descomenta y usa esta función si tu versión de Freqtrade la soporta.
        """
        dataframe["&-target"] = (
            (dataframe["close"].shift(-4) / dataframe["close"] - 1) > 0.01
        ).astype(int)

        return dataframe

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        FreqAI maneja los indicadores internamente via feature_engineering_*.
        Esta función queda mayormente vacía cuando se usa FreqAI.
        """
        # FreqAI se encarga de calcular features y predicciones
        dataframe = self.freqai.start(dataframe, metadata, self)

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Compra cuando el modelo predice subida con suficiente confianza.
        """
        dataframe.loc[
            (
                # El modelo predice clase 1 (subida)
                (dataframe["&-target_prediction"] == 1)
                # Con probabilidad superior al umbral
                & (dataframe["&-target_prediction_probability"] > self.entry_threshold.value)
                # Filtro de disimilitud — si los datos actuales son muy diferentes
                # a los datos de entrenamiento, no confiamos en la predicción
                & (dataframe["do_not_trade"] == 0)
                & (dataframe["volume"] > 0)
            ),
            "enter_long",
        ] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Vende cuando el modelo predice bajada con suficiente confianza.
        """
        dataframe.loc[
            (
                # El modelo predice clase 0 (bajada) con confianza
                (dataframe["&-target_prediction"] == 0)
                & (dataframe["&-target_prediction_probability"] > self.exit_threshold.value)
            ),
            "exit_long",
        ] = 1

        return dataframe

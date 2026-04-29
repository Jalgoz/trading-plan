"""
Estrategia: EMA Cross + RSI Filter (Fase 1 — Sin ML)

Lógica:
- ENTRADA (compra): EMA rápida (20) cruza POR ENCIMA de EMA lenta (50) Y RSI < 70
- SALIDA (venta): EMA rápida (20) cruza POR DEBAJO de EMA lenta (50) O RSI > 80
- Stoploss: -5% (protección contra caídas fuertes)
- ROI: toma de ganancias escalonada

Pares recomendados: BTC/USDT, ETH/USDT, SOL/USDT (1h timeframe)

IMPORTANTE: Esta es una estrategia educativa para entender Freqtrade.
NO es una estrategia rentable garantizada. Backtestea y valida antes de usar con dinero real.
"""

from freqtrade.strategy import IStrategy, IntParameter, DecimalParameter
from pandas import DataFrame
import talib.abstract as ta


class EmaCrossRsi(IStrategy):
    """
    Estrategia simple basada en cruce de EMAs con filtro RSI.
    Diseñada para aprender Freqtrade en Fase 1 del plan.
    """

    # Versión de la estrategia (incrementar al hacer cambios)
    INTERFACE_VERSION = 3

    # Timeframe de las velas
    timeframe = "1h"

    # Stoploss: -5% desde el precio de entrada
    stoploss = -0.05

    # Trailing stop: protege ganancias cuando el precio sube
    trailing_stop = True
    trailing_stop_positive = 0.01       # Activa trailing cuando tiene +1%
    trailing_stop_positive_offset = 0.02 # Solo activa si alcanza +2%
    trailing_only_offset_is_reached = True

    # ROI (Return on Investment) — toma de ganancias escalonada
    # "0": vende si tiene +8% en cualquier momento
    # "60": después de 60 minutos, vende si tiene +4%
    # "120": después de 120 minutos, vende si tiene +2%
    minimal_roi = {
        "0": 0.08,
        "60": 0.04,
        "120": 0.02,
    }

    # Solo comprar al inicio de una nueva vela (no a mitad de vela)
    process_only_new_candles = True

    # No usar señales de salida del order book
    use_exit_signal = True
    exit_profit_only = False
    ignore_roi_if_entry_signal = False

    # Número de velas necesarias para calcular indicadores
    startup_candle_count: int = 55

    # --- Parámetros optimizables (para Hyperopt en el futuro) ---
    ema_fast_period = IntParameter(10, 30, default=20, space="buy", optimize=True)
    ema_slow_period = IntParameter(40, 70, default=50, space="buy", optimize=True)
    rsi_period = IntParameter(10, 20, default=14, space="buy", optimize=True)
    rsi_buy_limit = IntParameter(20, 70, default=70, space="buy", optimize=True)
    rsi_sell_limit = IntParameter(70, 90, default=80, space="sell", optimize=True)

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Calcula todos los indicadores técnicos necesarios.
        Esta función se ejecuta para cada par y cada vela nueva.
        """
        # EMAs (Exponential Moving Averages)
        dataframe["ema_fast"] = ta.EMA(dataframe, timeperiod=self.ema_fast_period.value)
        dataframe["ema_slow"] = ta.EMA(dataframe, timeperiod=self.ema_slow_period.value)

        # RSI (Relative Strength Index) — mide sobrecompra/sobreventa
        dataframe["rsi"] = ta.RSI(dataframe, timeperiod=self.rsi_period.value)

        # Volumen promedio de 20 periodos (para filtrar pares con poco volumen)
        dataframe["volume_mean_20"] = dataframe["volume"].rolling(window=20).mean()

        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Define las condiciones para COMPRAR (entrar en posición).
        Columna 'enter_long' = 1 cuando se cumplen todas las condiciones.
        """
        dataframe.loc[
            (
                # Condición 1: EMA rápida cruza por encima de EMA lenta
                (dataframe["ema_fast"] > dataframe["ema_slow"])
                & (dataframe["ema_fast"].shift(1) <= dataframe["ema_slow"].shift(1))
                # Condición 2: RSI no está en sobrecompra (filtro de seguridad)
                & (dataframe["rsi"] < self.rsi_buy_limit.value)
                # Condición 3: Hay volumen (evita señales en mercado muerto)
                & (dataframe["volume"] > dataframe["volume_mean_20"] * 0.5)
                # Condición 4: Volumen no es cero
                & (dataframe["volume"] > 0)
            ),
            "enter_long",
        ] = 1

        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        Define las condiciones para VENDER (salir de posición).
        Columna 'exit_long' = 1 cuando se cumplen las condiciones.

        Nota: el stoploss y ROI también pueden cerrar la posición
        independientemente de estas señales.
        """
        dataframe.loc[
            (
                # Condición 1: EMA rápida cruza por debajo de EMA lenta (tendencia bajista)
                (
                    (dataframe["ema_fast"] < dataframe["ema_slow"])
                    & (dataframe["ema_fast"].shift(1) >= dataframe["ema_slow"].shift(1))
                )
                # O Condición 2: RSI en sobrecompra extrema
                | (dataframe["rsi"] > self.rsi_sell_limit.value)
            ),
            "exit_long",
        ] = 1

        return dataframe

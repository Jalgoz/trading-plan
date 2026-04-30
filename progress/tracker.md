# Progress Tracker - Algo Trading Bot

Marca cada item cuando lo completes. **No avances de fase sin completar todos los items.**

---

## FASE 0: Fundamentos de Trading (Semanas 1-3)

- [ ] Entiendo: order book, bid/ask spread, slippage, market vs limit orders
- [ ] Entiendo: velas OHLCV, timeframes (1m, 5m, 1h, 1d)
- [ ] Entiendo: RSI, EMA, MACD, Bollinger Bands (que miden, no como tradear)
- [ ] Entiendo: comisiones Binance (maker/taker 0.1%) y su impacto en P&L
- [ ] Entiendo: drawdown, sharpe ratio, win rate, profit factor, risk/reward ratio
- [ ] Cuenta de Binance creada (SIN depositar dinero)
- [ ] 10+ trades ficticios anotados en TradingView con analisis
- [ ] Puedo calcular breakeven considerando comisiones de entrada y salida

Recursos usados:
- [ ] Babypips School of Pipsology (al menos los primeros modulos)
- [ ] Binance Academy (articulos de conceptos basicos)

---

## FASE 1: Freqtrade + Estrategia sin ML (Semanas 4-7)

- [ ] Freqtrade corre en Docker sin errores
- [ ] Descargados 2 anios de datos OHLCV de pares principales
- [ ] Lei y entendi EmaCrossRsi.py linea por linea
- [ ] Mi estrategia EmaCrossRsi compila y ejecuta backtest
- [ ] Backtest en periodo TRAIN muestra profit factor >= 1.10
- [ ] Backtest en periodo VALIDATION muestra profit factor >= 1.10
- [ ] Backtest en periodo FINAL-TEST muestra profit factor >= 1.10
- [ ] Tengo minimo 100 trades historicos antes de confiar en el backtest
- [ ] Puedo explicar que es overfitting y como lo mitigo
- [ ] He probado al menos 3 variaciones de parametros
- [ ] He documentado resultados de cada variacion

Resultados de backtest:

| Variacion | Train PF | Validation PF | Final-test PF | Sharpe | Drawdown | Notas |
|-----------|----------|---------------|---------------|--------|----------|-------|
| v1: EMA 20/50, RSI 70 | | | | | | |
| v2: | | | | | | |
| v3: | | | | | | |

---

## FASE 2: Fundamentos de ML (Semanas 8-12)

- [ ] Complete un curso/tutorial de ML (no solo visto, sino ejecutado codigo)
- [ ] Entiendo: train/test/validation split
- [ ] Entiendo: por que NO se puede hacer random split en series temporales
- [ ] Entiendo: feature engineering (que features usar, cuales evitar)
- [ ] Entiendo: metricas (accuracy, precision, recall) y por que accuracy no basta
- [ ] Entiendo: overfitting, regularizacion, walk-forward validation
- [ ] Complete el notebook ml_fundamentals.ipynb con datos OHLCV
- [ ] Entrene un modelo LightGBM con walk-forward split
- [ ] Entiendo que 50% accuracy es normal y predecir precios es MUY dificil

Curso completado: ___________________

---

## FASE 3: FreqAI - ML integrado (Semanas 13-18)

- [ ] Lei la documentacion de FreqAI completa
- [ ] FreqAI corre backtest sin errores con LightGBM
- [ ] Tengo al menos 2 configuraciones de features/targets probadas
- [ ] Backtest FreqAI muestra resultados positivos en datos de validacion
- [ ] He comparado rendimiento ML vs estrategia EmaCrossRsi simple
- [ ] Puedo explicar el pipeline: features -> training -> prediction -> signal
- [ ] Feature importance revisada (no hay features basura dominando)

Resultados FreqAI:

| Config | Features | Target | Train PF | Test PF | Sharpe | vs Simple |
|--------|----------|--------|----------|---------|--------|-----------|
| v1 | | | | | | |
| v2 | | | | | | |

---

## FASE 4: Paper Trading (Semanas 19-30)

- [ ] Bot corriendo en dry-run 24/7
- [ ] Semana 1 completada - notas: ___
- [ ] Semana 2 completada - notas: ___
- [ ] Semana 3 completada - notas: ___
- [ ] Semana 4 completada - notas: ___
- [ ] Semana 5 completada - notas: ___
- [ ] Semana 6 completada - notas: ___
- [ ] Semana 7 completada - notas: ___
- [ ] Semana 8 completada - notas: ___ (minimo para pasar)
- [ ] Semana 9-12 completadas (ideal para FreqAI)
- [ ] Rendimiento paper esta dentro del rango del backtest (+-30%)
- [ ] Drawdown maximo no supera 15%
- [ ] NO modifique la estrategia durante el paper (invalida la prueba)
- [ ] Diario de trading con 50+ trades documentados (ideal 100+)

Metricas paper trading:

| Semana | Trades | Win Rate | P&L % | Drawdown % | Notas |
|--------|--------|----------|-------|------------|-------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |
| 8 | | | | | |

---

## FASE 5: Trading Real (Semanas 31+)

- [ ] Deposite $50 USD en Binance (NO $200 de golpe)
- [ ] API keys configuradas (solo trading, NO retiro)
- [ ] Protecciones activadas (stoploss, CooldownPeriod, StoplossGuard, MaxDrawdown, LowProfitPairs)
- [ ] Semana 1 real completada
- [ ] Semana 2 real completada
- [ ] Semana 3 real completada
- [ ] Semana 4 real completada
- [ ] Drawdown mensual no supera 5% (kill-switch del plan)
- [ ] Resultados reales dentro del rango del paper trading
- [ ] Decision: escalar a $100 / iterar estrategia / parar

---

## Bloque de decision de descarte

Si se cumple cualquiera de estos puntos, no se itera en caliente: se pausa y se descarta o rediseña.

- [ ] PF < 1.10 en validacion/final-test
- [ ] Drawdown > 15%
- [ ] Menos de 100 trades historicos
- [ ] Solo funciona en un par
- [ ] Dry-run difiere demasiado del backtest

Metricas trading real:

| Semana | Capital | Trades | Win Rate | P&L % | P&L $ | Drawdown % |
|--------|---------|--------|----------|-------|-------|------------|
| 1 | $50 | | | | | |
| 2 | | | | | | |
| 3 | | | | | | |
| 4 | | | | | | |

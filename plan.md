# Plan de Aprendizaje y Ejecucion: Bot de Algo Trading con ML (Freqtrade + FreqAI)

Plan progresivo y realista para un ingeniero en sistemas con Python y Docker, sin experiencia en trading ni ML, con $200 USD de capital y 1-2 horas diarias disponibles. Exchange: Binance. Spot primero, futuros despues.

---

## Disclaimer brutal

- **Con $200 USD en spot, si logras un 5% mensual consistente despues de meses de trabajo, estarias entre los mejores.** Eso es $10/mes. No vas a vivir de esto al inicio.
- **El 70-90% de traders retail pierden dinero.** Un bot no te exime de esto automaticamente.
- **ML en trading NO es una varita magica.** La mayoria de modelos ML aplicados ingenuamente a precios tienen performance peor que buy-and-hold.
- **Tu ventaja real no es el bot, es el proceso:** backtesting riguroso, gestion de riesgo, y disciplina para no operar hasta tener evidencia estadistica.
- **Tiempo total estimado hasta operar con dinero real con un minimo de confianza: 4-6 meses** (a 1-2h/dia).

---

## FASE 0: Fundamentos de Trading y Mercados (Semanas 1-3)

### Objetivo
Entender como funcionan los mercados crypto, la terminologia, y los mecanismos basicos antes de tocar una sola linea de codigo.

### Tareas concretas
1. **Leer y estudiar (no ver videos motivacionales):**
   - Que es un order book, bid/ask spread, slippage, market vs limit orders
   - Que son velas japonesas (OHLCV), timeframes (1m, 5m, 1h, 1d)
   - Indicadores tecnicos basicos: RSI, EMA, MACD, Bollinger Bands - que miden, no como tradear con ellos
   - Que son las comisiones de Binance (maker/taker: 0.1% spot) y como impactan tu P&L
   - Conceptos: drawdown, sharpe ratio, win rate, profit factor, risk/reward ratio
2. **Crear cuenta en Binance** y familiarizarte con la interfaz (NO depositar dinero aun)
3. **Paper trading manual:** abre TradingView (gratis), pon BTC/USDT en 1h, y anota en un cuaderno 10 trades ficticios con entrada, salida, razon, y resultado. Esto te dara intuicion.

### Herramientas
| Herramienta | Costo | Uso |
|---|---|---|
| TradingView (https://tradingview.com) | Gratis (plan basico) | Graficos, analisis visual |
| Binance Academy (https://academy.binance.com) | Gratis | Conceptos de trading y crypto |
| Investopedia (https://investopedia.com) | Gratis | Definiciones y conceptos financieros |
| babypips.com (https://babypips.com) School of Pipsology | Gratis | Curso estructurado de trading |

### Errores comunes
- **Saltarte esta fase** porque "ya quieres programar". Sin esto, tu bot sera una caja negra que no puedes evaluar.
- **Confundir indicadores con estrategias.** RSI > 70 no es una estrategia; es un dato.
- **Ver YouTube de "traders" que venden cursos.** La mayoria son charlatanes.

### Meta de salida (no avanzar sin cumplir)
- [ ] Puedes explicar: order book, spread, slippage, maker/taker fees
- [ ] Puedes leer un grafico de velas y nombrar los indicadores principales
- [ ] Tienes 10+ trades ficticios anotados con analisis
- [ ] Puedes calcular breakeven considerando comisiones

---

## FASE 1: Setup tecnico de Freqtrade + primera estrategia sin ML (Semanas 4-7)

### Objetivo
Tener Freqtrade corriendo en Docker, entender su arquitectura, y crear/backtestear una estrategia simple.

### Tareas concretas
1. Instalar Freqtrade con Docker (ver docker-compose.yml)
2. Descargar datos historicos (ver scripts/download_data.ps1)
3. Estudiar la estrategia EmaCrossRsi.py linea por linea
4. Backtestear con scripts/backtest.ps1
5. Iterar: cambiar parametros, probar en distintos timeranges

### Archivos del proyecto relevantes
- docker-compose.yml - Orquestacion Docker
- config/config-backtest.json - Configuracion de backtesting
- strategies/EmaCrossRsi.py - Estrategia EMA Cross + RSI
- scripts/download_data.ps1 - Descarga de datos
- scripts/backtest.ps1 - Ejecucion de backtesting

### Meta de salida
- [ ] Freqtrade corre en Docker sin errores
- [ ] Has descargado al menos 1 anio de datos OHLCV de 3+ pares
- [ ] Tu estrategia ejecuta un backtest completo
- [ ] Profit factor > 1.0 en datos de validacion
- [ ] Puedes explicar que es overfitting y como lo mitigas

---

## FASE 2: Fundamentos de ML para Trading (Semanas 8-12)

### Objetivo
Aprender Machine Learning suficiente para usarlo con criterio en trading.

### Tareas concretas
1. Curso practico de ML: fast.ai o Kaggle Learn
2. Dominar: walk-forward validation, feature engineering, LightGBM
3. Completar notebooks/ml_fundamentals.ipynb

### Archivos del proyecto relevantes
- notebooks/ml_fundamentals.ipynb - Notebook guiado de ML

### Meta de salida
- [ ] Curso de ML completado (ejecutando codigo, no solo viendo)
- [ ] Notebook funcional con walk-forward split
- [ ] Entiendes que ~50% accuracy es normal

---

## FASE 3: FreqAI - ML integrado en Freqtrade (Semanas 13-18)

### Objetivo
Integrar ML en Freqtrade usando FreqAI y backtestear estrategias ML-based.

### Tareas concretas
1. Estudiar documentacion FreqAI
2. Configurar FreqAI con LightGBM (ver config-backtest-freqai.json)
3. Backtestear con scripts/backtest_freqai.ps1
4. Comparar ML vs estrategia simple

### Archivos del proyecto relevantes
- config/config-backtest-freqai.json - Config FreqAI con LightGBM
- strategies/FreqaiLightgbm.py - Estrategia ML
- scripts/backtest_freqai.ps1 - Backtest con FreqAI

### Meta de salida
- [ ] FreqAI corre backtest sin errores
- [ ] 2+ configuraciones probadas
- [ ] Comparacion ML vs simple documentada

---

## FASE 4: Paper Trading (Semanas 19-24)

### Tareas
1. Configurar dry-run (ver config/config-dryrun.json)
2. Ejecutar scripts/dryrun.ps1
3. Monitorear en FreqUI (http://localhost:8080)
4. 4+ semanas minimo

### Archivos del proyecto relevantes
- config/config-dryrun.json - Config paper trading
- scripts/dryrun.ps1 - Iniciar paper trading
- progress/journal.md - Diario de trading

---

## FASE 5: Trading Real (Semanas 25-30+)

### Tareas
1. Copiar config-live.example.json a config-live.json
2. Agregar API keys de Binance
3. Ejecutar scripts/live.ps1
4. Empezar con $50, NO $200

### Archivos del proyecto relevantes
- config/config-live.example.json - Template para trading real
- scripts/live.ps1 - Iniciar trading real (con confirmacion)

---

## Retornos realistas

| Escenario | Retorno mensual |
|---|---|
| Malo pero comun | -5% a -15% |
| Breakeven | -2% a +2% |
| Decente | +2% a +5% |
| Muy bueno | +5% a +10% |
| Fantasia | +20%+ |

Con $200 y +3% mensual = ~$6/mes. No es para vivir de esto al inicio.

---

## Timeline

| Fase | Duracion | Horas |
|---|---|---|
| Fase 0 | 3 semanas | 20-40h |
| Fase 1 | 4 semanas | 30-50h |
| Fase 2 | 5 semanas | 40-60h |
| Fase 3 | 6 semanas | 50-70h |
| Fase 4 | 6 semanas | 15-25h |
| Fase 5 | 6+ semanas | 15-25h |
| TOTAL | ~30 semanas | ~170-270h |

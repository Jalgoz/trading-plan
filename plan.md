# Plan de Aprendizaje y Ejecucion: Bot de Algo Trading con ML (Freqtrade + FreqAI)

Plan progresivo para un ingeniero con Python/Docker, sin experiencia previa en trading o ML, con $200 USD y 1-2 horas diarias. Exchange: Binance Spot.

Futuros no forman parte de la ruta normal: quedan fuera de alcance hasta acumular 6-12 meses rentables y auditables en spot.

---

## Disclaimer brutal

- Con $200 USD en spot, incluso 5% mensual consistente son ~$10/mes.
- 70-90% de traders retail pierden dinero.
- ML en trading no es magia; puede rendir peor que buy-and-hold.
- Tu ventaja es el proceso: validacion estadistica, control de riesgo y disciplina.
- Tiempo estimado razonable para llegar a live: 7-9 meses (no 4 semanas de prueba).

---

## Criterios duros de descarte (aplican en todas las fases)

Si se cumple uno de estos puntos, la idea/estrategia se descarta o vuelve a iteracion:

- Profit Factor < 1.10 en validacion o final-test
- Drawdown maximo > 15%
- Menos de 100 trades historicos en el periodo evaluado
- Solo funciona en un par y falla en el resto
- Dry-run difiere demasiado del backtest (estructura de resultados inconsistente)

---

## FASE 0: Fundamentos de Trading y Riesgo (Semanas 1-3)

### Objetivo
Entender mercado, ejecucion y riesgo antes de escribir estrategia.

### Tareas concretas
1. Estudiar: order book, spread, slippage, market/limit, comisiones.
2. Estudiar: OHLCV, timeframes, drawdown, sharpe, profit factor, expectativa.
3. Crear cuenta en Binance sin depositar.
4. Hacer 10+ trades manuales ficticios y documentar razonamiento.

### Archivos del proyecto relevantes
- `plan.md` - Marco general de fases, criterios y tiempos.
- `progress/tracker.md` - Checklist operativo por fase.
- `progress/journal.md` - Registro de aprendizaje y errores.

### Errores comunes
- Saltar esta fase por querer programar rapido.
- Confundir indicador con estrategia completa.
- Ignorar costos de ejecucion (fee, spread, slippage).

### Meta de salida
- [ ] Puedes explicar costos reales de ejecucion
- [ ] Puedes calcular breakeven con fees
- [ ] Tienes 10+ ejemplos documentados

---

## FASE 1: Baseline sin ML en Freqtrade (Semanas 4-7)

### Objetivo
Tener una baseline reproducible con Freqtrade para comparar todo lo demas.

### Tareas concretas
1. Correr Freqtrade en Docker.
2. Descargar datos historicos suficientes.
3. Auditar y entender `EmaCrossRsi.py` como benchmark educativo.
4. Ejecutar backtest con split `train / validation / final-test`.
5. Registrar resultados por corrida.

### Archivos del proyecto relevantes
- `docker-compose.yml` - Ejecucion base de Freqtrade.
- `config/config-backtest.json` - Parametros de backtesting baseline.
- `strategies/EmaCrossRsi.py` - Estrategia baseline educativa.
- `scripts/download_data.ps1` - Descarga OHLCV.
- `scripts/backtest.ps1` - Backtest train/validation/final-test.

### Errores comunes
- Optimizar en train y "creer" sin final-test.
- Usar muestra chica de trades (<100).
- Cambiar muchas variables a la vez y perder trazabilidad.

### Meta de salida
- [ ] Backtests reproducibles sin errores
- [ ] PF >= 1.10 en validation y final-test
- [ ] Drawdown <= 15%
- [ ] 100+ trades historicos

---

## FASE 2: Fundamentos de ML para Trading (Semanas 8-12)

### Objetivo
Aprender ML suficiente para no caer en overfitting o validaciones falsas.

### Tareas concretas
1. Curso practico (fast.ai o Kaggle Learn).
2. Dominar walk-forward y leakage/look-ahead bias.
3. Completar `notebooks/ml_fundamentals.ipynb` con datos reales de Freqtrade.

### Archivos del proyecto relevantes
- `notebooks/ml_fundamentals.ipynb` - Practica guiada de ML para trading.
- `progress/journal.md` - Registro de hipotesis, resultados y decisiones.

### Errores comunes
- Basarse solo en accuracy para validar un modelo.
- Usar datos sinteticos como validacion principal.
- Hacer random split en series temporales.

### Meta de salida
- [ ] Notebook ejecutado con datos reales
- [ ] Entiendes distribucion de labels
- [ ] Aceptas que accuracy sola no valida estrategia

---

## FASE 3: FreqAI integrado (Semanas 13-18)

### Objetivo
Usar ML como filtro de señal, no como reemplazo ciego de logica tecnica.

### Tareas concretas
1. Validar estrategia FreqAI con la version exacta instalada.
2. Usar pipeline oficial de features (`%`) y targets (`&`).
3. Probar 2+ configuraciones y cambiar `identifier` por experimento.
4. Comparar contra baseline sin ML con metricas de trading.

### Archivos del proyecto relevantes
- `strategies/FreqaiLightgbm.py` - Estrategia ML con filtro tecnico.
- `config/config-backtest-freqai.json` - Configuracion FreqAI y entrenamiento.
- `scripts/backtest_freqai.ps1` - Backtest ML + comparacion baseline.
- `progress/reports/` - Resumenes por corrida ML vs baseline; se genera automaticamente al correr `scripts/backtest_freqai.ps1`.

### Errores comunes
- No cambiar `identifier` entre experimentos.
- Usar ML como senal unica sin filtro tecnico.
- No revisar distribucion de labels y degeneracion de clase.

### Meta de salida
- [ ] ML mejora algo medible (PF, DD, expectativa o calidad de trades)
- [ ] Hay resumen ML vs baseline por corrida
- [ ] No hay evidencia de sobreoptimizacion en validacion/final-test

---

## FASE 4: Paper Trading (Semanas 19-30)

### Regla principal
Minimo 8 semanas continuas; ideal 12 semanas. Cuatro semanas es un minimo tecnico, no criterio suficiente para pasar a dinero real.

### Tareas
1. Configurar dry-run con protecciones activas.
2. Ejecutar `scripts/dryrun.ps1` y monitorear diario.
3. No cambiar estrategia durante el periodo de evaluacion.
4. Validar convergencia con backtest.

### Archivos del proyecto relevantes
- `config/config-dryrun.json` - Configuracion de paper trading.
- `scripts/dryrun.ps1` - Arranque y validaciones previas.
- `progress/journal.md` - Bitacora de ejecucion diaria.
- `progress/tracker.md` - Control de avance semanal.

### Errores comunes
- Quedarse en 2-4 semanas y pasar a live prematuramente.
- Modificar estrategia durante la prueba y contaminar resultados.
- Ignorar divergencias entre dry-run y backtest.

### Meta de salida
- [ ] 8-12 semanas completadas
- [ ] Minimo 50 trades (ideal 100+)
- [ ] Drawdown controlado <= 15%
- [ ] Backtest y dry-run son consistentes

---

## FASE 5: Trading Real con micro-capital (Semanas 31+)

### Objetivo
Validar ejecucion real (ordenes, fees, slippage, latencia), no maximizar rentabilidad inmediata.

### Capital real esperado

- Inicio sugerido: $50 o $100.
- $200 completo solo despues de estabilidad comprobada.
- Meta inicial: confiabilidad operativa y control de riesgo.

### Reglas de apagado (kill switch)

Parar live y volver a Fase 3/4 si ocurre cualquiera:

- Drawdown mensual > 5%
- 5 perdidas consecutivas
- Divergencia marcada live vs dry-run
- Modelo predice casi siempre la misma clase
- Errores repetidos de exchange/API

### Archivos del proyecto relevantes
- `config/config-live.example.json` - Plantilla de live con protecciones.
- `scripts/live.ps1` - Validaciones estrictas antes de operar.
- `progress/journal.md` - Auditoria de cada trade real.

### Errores comunes
- Entrar con capital completo desde el primer dia.
- Operar sin alertas activas (Telegram) y sin monitoreo.
- Ignorar reglas de apagado por sesgo emocional.

---

## Retornos realistas

| Escenario | Retorno mensual |
|---|---|
| Malo pero comun | -5% a -15% |
| Breakeven | -2% a +2% |
| Decente | +2% a +5% |
| Muy bueno | +5% a +10% |
| Fantasia | +20%+ |

Con $200 y +3% mensual son ~$6/mes. Al inicio la prioridad es proceso, no ingreso.

---

## Timeline unificado

| Fase | Duracion | Horas estimadas |
|---|---|---|
| Fase 0 | 3 semanas | 20-40h |
| Fase 1 | 4 semanas | 30-50h |
| Fase 2 | 5 semanas | 40-60h |
| Fase 3 | 6 semanas | 50-70h |
| Fase 4 | 8-12 semanas | 25-45h + monitoreo |
| Fase 5 | 6+ semanas | 20-40h + monitoreo |
| TOTAL | ~32-36 semanas | ~185-305h |

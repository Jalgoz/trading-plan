# Archivos Clave para Entender el Proyecto

Guia rapida de lectura para entender como se ejecuta el bot de punta a punta.

## Orden sugerido de lectura

1. `INSTALL_FREQTRADE.md`
2. `README.md`
3. `plan.md`
4. `config/config-backtest.json`
5. `scripts/download_data.ps1`
6. `strategies/EmaCrossRsi.py`
7. `scripts/backtest.ps1`
8. `config/config-backtest-freqai.json`
9. `strategies/FreqaiLightgbm.py`
10. `scripts/backtest_freqai.ps1`
11. `config/config-dryrun.json`
12. `scripts/dryrun.ps1`
13. `config/config-live.example.json`
14. `scripts/live.ps1`

## Que hace cada tipo de archivo

- `strategies/*.py`
  - Definen la logica de trading: indicadores, entradas, salidas y tags.
  - Cada metodo principal esta documentado con Args/Returns y logica.

- `scripts/*.ps1`
  - Ejecutan flujos operativos repetibles: descarga, backtests, dry-run y live.
  - Incluyen ayuda estilo PowerShell (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`).

- `config/*.json`
  - Definen pares, stake, fees, API server, Telegram y opciones de FreqAI.
  - Las protecciones de riesgo viven en las estrategias y se activan con `--enable-protections` en backtesting.
  - Deben mantenerse consistentes entre backtest, dry-run y live.

## Checklist minimo antes de live

- Dry-run 8-12 semanas con resultados estables.
- Convergencia razonable backtest vs dry-run.
- Drawdown controlado y reglas de apagado definidas.
- `scripts/live.ps1` sin validaciones fallidas.

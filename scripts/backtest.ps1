# backtest.ps1 — Ejecuta backtesting de la estrategia EmaCrossRsi (Fase 1)
# Uso: .\scripts\backtest.ps1
#
# IMPORTANTE: Separa train y test para detectar overfitting
# - Primer backtest (train): 2023-01-01 a 2024-06-30
# - Segundo backtest (test):  2024-07-01 a 2025-01-01
# Si la estrategia solo funciona en train pero no en test, hay overfitting.

param(
    [string]$Strategy = "EmaCrossRsi",
    [string]$TimerangeTrain = "20230101-20240630",
    [string]$TimerangeTest = "20240701-20250101"
)

Write-Host "=== BACKTEST: $Strategy ===" -ForegroundColor Cyan
Write-Host ""

# --- Backtest en periodo de ENTRENAMIENTO ---
Write-Host "[1/2] Backtesting en periodo TRAIN ($TimerangeTrain)..." -ForegroundColor Yellow

docker compose run --rm freqtrade backtesting `
    --config /freqtrade/config/config-backtest.json `
    --strategy $Strategy `
    --timerange $TimerangeTrain `
    --timeframe 1h `
    --export trades

Write-Host ""

# --- Backtest en periodo de VALIDACION ---
Write-Host "[2/2] Backtesting en periodo TEST ($TimerangeTest)..." -ForegroundColor Yellow

docker compose run --rm freqtrade backtesting `
    --config /freqtrade/config/config-backtest.json `
    --strategy $Strategy `
    --timerange $TimerangeTest `
    --timeframe 1h `
    --export trades

Write-Host ""
Write-Host "=== BACKTEST COMPLETADO ===" -ForegroundColor Green
Write-Host ""
Write-Host "SIGUIENTE PASO:" -ForegroundColor Cyan
Write-Host "  Compara los resultados de TRAIN vs TEST." -ForegroundColor White
Write-Host "  Si TEST es mucho peor que TRAIN, hay overfitting." -ForegroundColor White
Write-Host "  Resultados en: user_data/backtest_results/" -ForegroundColor Gray

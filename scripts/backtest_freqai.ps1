# backtest_freqai.ps1 — Ejecuta backtesting con FreqAI + LightGBM (Fase 3)
# Uso: .\scripts\backtest_freqai.ps1
#
# NOTA: El backtest con FreqAI es MUCHO más lento que el normal porque
# entrena el modelo ML en cada ventana. Puede tardar 30-60 minutos.

param(
    [string]$Strategy = "FreqaiLightgbm",
    [string]$Timerange = "20230101-20250101",
    [string]$Model = "LightGBMClassifier"
)

Write-Host "=== BACKTEST FreqAI: $Strategy ===" -ForegroundColor Cyan
Write-Host "Modelo: $Model" -ForegroundColor Yellow
Write-Host "Timerange: $Timerange" -ForegroundColor Yellow
Write-Host ""
Write-Host "ADVERTENCIA: Esto puede tardar 30-60 minutos." -ForegroundColor Red
Write-Host ""

docker compose run --rm freqtrade backtesting `
    --config /freqtrade/config/config-backtest-freqai.json `
    --strategy $Strategy `
    --freqaimodel $Model `
    --timerange $Timerange `
    --timeframe 1h `
    --export trades

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== BACKTEST FreqAI COMPLETADO ===" -ForegroundColor Green
    Write-Host "Resultados en: user_data/backtest_results/" -ForegroundColor Gray
    Write-Host "Modelos guardados en: user_data/models/" -ForegroundColor Gray
} else {
    Write-Host "`nError en backtest FreqAI." -ForegroundColor Red
    Write-Host "Verifica que el bloque 'freqai' este en tu config." -ForegroundColor Yellow
}

# download_data.ps1 — Descarga datos históricos OHLCV de Binance
# Uso: .\scripts\download_data.ps1
# Descarga 1 año de datos en timeframes 1h y 4h para 5 pares principales

$pairs = "BTC/USDT ETH/USDT SOL/USDT BNB/USDT XRP/USDT"
$timeframes = "1h 4h"
$days = 730  # 2 años de datos (más datos = mejor backtest)

Write-Host "Descargando datos historicos de Binance..." -ForegroundColor Cyan
Write-Host "Pares: $pairs" -ForegroundColor Yellow
Write-Host "Timeframes: $timeframes" -ForegroundColor Yellow
Write-Host "Dias: $days" -ForegroundColor Yellow
Write-Host ""

docker compose run --rm freqtrade download-data `
    --config /freqtrade/config/config-backtest.json `
    --exchange binance `
    --pairs $pairs.Split(" ") `
    --timeframes $timeframes.Split(" ") `
    --days $days `
    --dataformat-ohlcv feather

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nDatos descargados exitosamente!" -ForegroundColor Green
    Write-Host "Ubicacion: user_data/data/binance/" -ForegroundColor Gray
} else {
    Write-Host "`nError al descargar datos. Verifica que Docker este corriendo." -ForegroundColor Red
}

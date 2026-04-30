<#
.SYNOPSIS
Descarga datos OHLCV historicos desde Binance usando Freqtrade.

.DESCRIPTION
Este script prepara datos para backtesting baseline y FreqAI.
Permite dos modos de rango temporal:
1) Por cantidad de dias (--days).
2) Por timerange explicito (--timerange YYYYMMDD-YYYYMMDD).

.PARAMETER Pairs
Lista de pares a descargar (formato EXCHANGE/QUOTE, por ejemplo BTC/USDT).

.PARAMETER Timeframes
Lista de timeframes a descargar (por ejemplo 1h, 4h).

.PARAMETER Days
Cantidad de dias historicos cuando no se usa -Timerange.

.PARAMETER Timerange
Rango explicito para descarga. Si se define, tiene prioridad sobre -Days.

.EXAMPLE
.\scripts\download_data.ps1

.EXAMPLE
.\scripts\download_data.ps1 -Days 1000

.EXAMPLE
.\scripts\download_data.ps1 -Pairs BTC/USDT,ETH/USDT -Timeframes 1h -Timerange "20220101-20260101"

.NOTES
Para FreqAI, conviene descargar velas extra antes del timerange objetivo para cubrir
train_period_days + startup_candle_count.
#>

param(
    [string[]]$Pairs = @("BTC/USDT", "ETH/USDT", "SOL/USDT"),
    [string[]]$Timeframes = @("1h", "4h"),
    [int]$Days = 730,
    [string]$Timerange = ""
)

# --- Logging de parametros de ejecucion ---
Write-Host "Descargando datos historicos de Binance..." -ForegroundColor Cyan
Write-Host "Pares: $($Pairs -join ', ')" -ForegroundColor Yellow
Write-Host "Timeframes: $($Timeframes -join ', ')" -ForegroundColor Yellow

if ([string]::IsNullOrWhiteSpace($Timerange)) {
    Write-Host "Modo: dias -> $Days" -ForegroundColor Yellow
} else {
    Write-Host "Modo: timerange -> $Timerange" -ForegroundColor Yellow
    Write-Host "Tip FreqAI: descarga datos extra antes del timerange para train_period_days + startup_candle_count." -ForegroundColor DarkYellow
}
Write-Host ""

$args = @(
    "compose", "run", "--rm", "freqtrade", "download-data",
    "--config", "/freqtrade/config/config-backtest.json",
    "--exchange", "binance",
    "--pairs"
) + $Pairs + @(
    "--timeframes"
) + $Timeframes

if ([string]::IsNullOrWhiteSpace($Timerange)) {
    $args += @("--days", "$Days")
} else {
    $args += @("--timerange", $Timerange)
}

$args += @("--dataformat-ohlcv", "feather")

# --- Ejecucion principal ---
& docker @args

# --- Manejo de resultado ---
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nDatos descargados exitosamente." -ForegroundColor Green
    Write-Host "Ubicacion: user_data/data/binance/" -ForegroundColor Gray
} else {
    Write-Host "`nError al descargar datos. Verifica Docker y parametros." -ForegroundColor Red
    exit 1
}

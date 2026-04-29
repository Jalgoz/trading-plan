# live.ps1 — Inicia trading real (Fase 5)
# Uso: .\scripts\live.ps1
#
# !!! SOLO USAR DESPUES DE COMPLETAR 4+ SEMANAS DE PAPER TRADING EXITOSO !!!
#
# Antes de ejecutar:
# 1. Copia config/config-live.example.json → config/config-live.json
# 2. Agrega tus API keys de Binance (solo permisos de trading, NO retiro)
# 3. Cambia los passwords y tokens de seguridad
# 4. Empieza con $50, NO $200

param(
    [string]$Strategy = "EmaCrossRsi"
)

# Verificación de seguridad
$configPath = Join-Path $PSScriptRoot "..\config\config-live.json"
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: config/config-live.json no existe." -ForegroundColor Red
    Write-Host "Copia config-live.example.json y agrega tus API keys." -ForegroundColor Yellow
    exit 1
}

Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Write-Host "!!!       TRADING REAL CON DINERO REAL       !!!" -ForegroundColor Red
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Write-Host ""
Write-Host "Estrategia: $Strategy" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Escribe 'CONFIRMO' para iniciar trading real"
if ($confirm -ne "CONFIRMO") {
    Write-Host "Cancelado." -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "Iniciando bot en modo LIVE..." -ForegroundColor Cyan
Write-Host "FreqUI: http://localhost:8080" -ForegroundColor Green
Write-Host ""

docker compose run --rm -p 8080:8080 freqtrade trade `
    --config /freqtrade/config/config-live.json `
    --strategy $Strategy

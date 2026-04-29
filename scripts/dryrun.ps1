# dryrun.ps1 — Inicia paper trading (Fase 4)
# Uso: .\scripts\dryrun.ps1
#
# El bot operará con dinero ficticio ($200 USDT) en datos de mercado reales.
# FreqUI estará disponible en http://localhost:8080 (user: freqtrade, pass: freqtrade)
#
# NOTA: Dejar corriendo mínimo 4 semanas antes de pasar a trading real.

param(
    [string]$Strategy = "EmaCrossRsi"
)

Write-Host "=== INICIANDO PAPER TRADING (DRY-RUN) ===" -ForegroundColor Cyan
Write-Host "Estrategia: $Strategy" -ForegroundColor Yellow
Write-Host "Wallet ficticio: 200 USDT" -ForegroundColor Yellow
Write-Host "FreqUI: http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el bot." -ForegroundColor Gray
Write-Host ""

docker compose run --rm -p 8080:8080 freqtrade trade `
    --config /freqtrade/config/config-dryrun.json `
    --strategy $Strategy

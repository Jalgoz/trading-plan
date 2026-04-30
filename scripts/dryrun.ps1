<#
.SYNOPSIS
Inicia paper trading (dry-run) con validaciones basicas de seguridad.

.DESCRIPTION
Lanza Freqtrade en modo dry-run para validar comportamiento en mercado real
sin usar dinero real. Antes de iniciar, revisa:
- existencia de config-dryrun.json,
- estado de Telegram,
- credenciales API server potencialmente debiles.

.PARAMETER Strategy
Nombre de estrategia Freqtrade a ejecutar en dry-run.

.PARAMETER Model
Modelo FreqAI usado automaticamente cuando Strategy es FreqaiLightgbm.

.EXAMPLE
.\scripts\dryrun.ps1

.EXAMPLE
.\scripts\dryrun.ps1 -Strategy FreqaiLightgbm

.NOTES
Mantener la prueba 8-12 semanas sin cambiar estrategia para que sea valida.
#>

param(
    [string]$Strategy = "EmaCrossRsi",
    [string]$Model = "LightGBMClassifier"
)

# --- Cargar y validar configuracion ---
$configPath = Join-Path $PSScriptRoot "..\config\config-dryrun.json"
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: No existe config/config-dryrun.json" -ForegroundColor Red
    exit 1
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

# --- Warnings operativos (no bloqueantes) ---
if (-not $config.telegram.enabled) {
    Write-Host "WARNING: Telegram esta desactivado en dry-run." -ForegroundColor Yellow
    Write-Host "Activalo para monitoreo prolongado y alertas de errores." -ForegroundColor DarkYellow
}

if ($config.api_server.username -match "freqtrade" -or $config.api_server.password -match "freqtrade") {
    Write-Host "WARNING: Credenciales API server parecen por defecto/debiles." -ForegroundColor Yellow
    Write-Host "Cambia username/password en config-dryrun.json." -ForegroundColor DarkYellow
}

if ($Strategy -eq "FreqaiLightgbm") {
    if (-not $config.freqai -or -not $config.freqai.enabled) {
        Write-Host "ERROR: FreqaiLightgbm requiere bloque freqai.enabled=true en config-dryrun.json." -ForegroundColor Red
        exit 1
    }
}

# --- Informacion de inicio ---
Write-Host "=== INICIANDO PAPER TRADING (DRY-RUN) ===" -ForegroundColor Cyan
Write-Host "Estrategia: $Strategy" -ForegroundColor Yellow
Write-Host "Wallet ficticio: $($config.dry_run_wallet) USDT" -ForegroundColor Yellow
Write-Host "FreqUI: http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "Presiona Ctrl+C para detener el bot." -ForegroundColor Gray
Write-Host ""

# --- Ejecucion principal ---
$args = @(
    "compose", "run", "--rm", "-p", "127.0.0.1:8080:8080", "freqtrade", "trade",
    "--config", "/freqtrade/config/config-dryrun.json",
    "--strategy", $Strategy
)

if ($Strategy -eq "FreqaiLightgbm") {
    $args += @("--freqaimodel", $Model)
}

& docker @args

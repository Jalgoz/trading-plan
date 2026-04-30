<#
.SYNOPSIS
Inicia trading real con validaciones estrictas previas.

.DESCRIPTION
Este script esta disenado para evitar arranques live inseguros.
Antes de ejecutar ordenes reales valida:
- config-live.json presente,
- claves/scretos sin placeholders,
- password y jwt del api server no default,
- initial_state en "stopped",
- Telegram habilitado y configurado.

Si cualquier validacion falla, aborta la ejecucion.

.PARAMETER Strategy
Nombre de estrategia Freqtrade a ejecutar en live.

.PARAMETER Model
Modelo FreqAI usado automaticamente cuando Strategy es FreqaiLightgbm.

.EXAMPLE
.\scripts\live.ps1

.EXAMPLE
.\scripts\live.ps1 -Strategy FreqaiLightgbm

.NOTES
Requiere confirmacion manual explicita: I_ACCEPT_REAL_MONEY_RISK.
#>

param(
    [string]$Strategy = "EmaCrossRsi",
    [string]$Model = "LightGBMClassifier"
)

function Test-PlaceholderValue {
    <#
    .SYNOPSIS
    Detecta valores vacios o placeholders de configuracion.

    .DESCRIPTION
    Usa patrones comunes (TU_, CAMBIA, REPLACE, etc.) para bloquear
    ejecuciones live con campos no finalizados.

    .PARAMETER Value
    Valor de texto a validar.

    .OUTPUTS
    System.Boolean
    #>
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $true
    }

    $patterns = @("TU_", "CAMBIA", "CHANGE", "REPLACE", "AQUI", "PLACEHOLDER")
    foreach ($pattern in $patterns) {
        if ($Value.ToUpper().Contains($pattern)) {
            return $true
        }
    }
    return $false
}

# --- Verificacion de seguridad: archivo de config ---
$configPath = Join-Path $PSScriptRoot "..\config\config-live.json"
if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: config/config-live.json no existe." -ForegroundColor Red
    Write-Host "Copia config-live.example.json y agrega tus API keys." -ForegroundColor Yellow
    exit 1
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

$errors = @()

# --- Verificacion de placeholders y campos criticos ---
if (Test-PlaceholderValue -Value $config.exchange.key) {
    $errors += "exchange.key esta vacio o en placeholder."
}
if (Test-PlaceholderValue -Value $config.exchange.secret) {
    $errors += "exchange.secret esta vacio o en placeholder."
}
if (Test-PlaceholderValue -Value $config.api_server.password) {
    $errors += "api_server.password esta vacio o en placeholder."
}
if (Test-PlaceholderValue -Value $config.api_server.jwt_secret_key) {
    $errors += "api_server.jwt_secret_key esta vacio o en placeholder."
}
if (Test-PlaceholderValue -Value $config.api_server.ws_token) {
    $errors += "api_server.ws_token esta vacio o en placeholder."
}
if ($config.initial_state -ne "stopped") {
    $errors += "initial_state debe ser 'stopped' para arranque controlado."
}
if (-not $config.telegram.enabled) {
    $errors += "telegram.enabled debe ser true antes de operar live."
}
if (Test-PlaceholderValue -Value $config.telegram.token) {
    $errors += "telegram.token invalido o placeholder."
}
if (Test-PlaceholderValue -Value $config.telegram.chat_id) {
    $errors += "telegram.chat_id invalido o placeholder."
}
if ($Strategy -eq "FreqaiLightgbm" -and (-not $config.freqai -or -not $config.freqai.enabled)) {
    $errors += "FreqaiLightgbm requiere bloque freqai.enabled=true en config-live.json."
}

# --- Abortar si hay validaciones fallidas ---
if ($errors.Count -gt 0) {
    Write-Host "ERROR: Validaciones de seguridad fallaron:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host " - $err" -ForegroundColor Yellow
    }
    Write-Host "Corrige config/config-live.json antes de iniciar live." -ForegroundColor Red
    exit 1
}

# --- Validacion final con Freqtrade ---
Write-Host "Validando config-live.json con freqtrade show-config..." -ForegroundColor Cyan
$showConfigArgs = @(
    "compose", "run", "--rm", "freqtrade", "show-config",
    "--config", "/freqtrade/config/config-live.json",
    "--strategy", $Strategy
)

if ($Strategy -eq "FreqaiLightgbm") {
    $showConfigArgs += @("--freqaimodel", $Model)
}

& docker @showConfigArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Freqtrade no pudo resolver/validar config-live.json." -ForegroundColor Red
    Write-Host "Corrige la configuracion antes de iniciar live." -ForegroundColor Yellow
    exit 1
}

# --- Banner de riesgo ---
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Write-Host "!!!       TRADING REAL CON DINERO REAL       !!!" -ForegroundColor Red
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Write-Host ""
Write-Host "Estrategia: $Strategy" -ForegroundColor Yellow
Write-Host "Capital recomendado de inicio: 50-100 USDT" -ForegroundColor Yellow
Write-Host "Recuerda: API de Binance debe tener trading ON y retiro OFF." -ForegroundColor DarkYellow
Write-Host ""

# --- Confirmacion explicita de riesgo real ---
$confirm = Read-Host "Escribe EXACTAMENTE I_ACCEPT_REAL_MONEY_RISK para iniciar"
if ($confirm -ne "I_ACCEPT_REAL_MONEY_RISK") {
    Write-Host "Cancelado." -ForegroundColor Gray
    exit 0
}

# --- Ejecucion live ---
Write-Host ""
Write-Host "Iniciando bot en modo LIVE..." -ForegroundColor Cyan
Write-Host "FreqUI: http://localhost:8080" -ForegroundColor Green
Write-Host ""

$args = @(
    "compose", "run", "--rm", "-p", "127.0.0.1:8080:8080", "freqtrade", "trade",
    "--config", "/freqtrade/config/config-live.json",
    "--strategy", $Strategy
)

if ($Strategy -eq "FreqaiLightgbm") {
    $args += @("--freqaimodel", $Model)
}

& docker @args

<#
.SYNOPSIS
Ejecuta backtesting baseline en tres ventanas temporales.

.DESCRIPTION
Corre la estrategia indicada en 3 etapas separadas para reducir riesgo de overfitting:
1) Train
2) Validation
3) Final-test (intocable para decisiones de paso)

Cada etapa exporta resultados con nombre unico (timestamp + estrategia + etapa)
para mantener trazabilidad historica.

.PARAMETER Strategy
Nombre de estrategia Freqtrade a evaluar (ej. EmaCrossRsi).

.PARAMETER TimerangeTrain
Rango temporal para entrenamiento / ajuste inicial.

.PARAMETER TimerangeValidation
Rango temporal para validacion intermedia.

.PARAMETER TimerangeFinalTest
Rango temporal final fuera de ajuste para decidir descarte/paso.

.EXAMPLE
.\scripts\backtest.ps1

.EXAMPLE
.\scripts\backtest.ps1 -Strategy EmaCrossRsi -TimerangeTrain 20210101-20231231
#>

param(
    [string]$Strategy = "EmaCrossRsi",
    [string]$TimerangeTrain = "20220101-20231231",
    [string]$TimerangeValidation = "20240101-20240930",
    [string]$TimerangeFinalTest = "20241001-20250331"
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$exportDir = "/freqtrade/user_data/backtest_results"

function Invoke-Backtest {
    <#
    .SYNOPSIS
    Ejecuta una etapa de backtest y exporta resultado.

    .DESCRIPTION
    Lanza `freqtrade backtesting` para una ventana especifica y valida exit code.
    Si falla, detiene la ejecucion completa para evitar resultados parciales.

    .PARAMETER Stage
    Etiqueta visible de etapa (ej. "1/3 TRAIN").

    .PARAMETER Range
    Timerange de la etapa actual.

    .PARAMETER FileName
    Nombre de archivo de salida en user_data/backtest_results.
    #>
    param(
        [string]$Stage,
        [string]$Range,
        [string]$FileName
    )

    Write-Host "[$Stage] Backtesting $Range ..." -ForegroundColor Yellow

    docker compose run --rm freqtrade backtesting `
        --config /freqtrade/config/config-backtest.json `
        --strategy $Strategy `
        --timerange $Range `
        --timeframe 1h `
        --enable-protections `
        --export trades `
        --export-filename "$exportDir/$FileName"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en etapa $Stage." -ForegroundColor Red
        exit 1
    }

    Write-Host "Archivo exportado: user_data/backtest_results/$FileName" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=== BACKTEST BASELINE: $Strategy ===" -ForegroundColor Cyan
Write-Host "Train: $TimerangeTrain" -ForegroundColor DarkCyan
Write-Host "Validation: $TimerangeValidation" -ForegroundColor DarkCyan
Write-Host "Final-test: $TimerangeFinalTest" -ForegroundColor DarkCyan
Write-Host ""

# --- Ejecucion secuencial por etapas ---
Invoke-Backtest -Stage "1/3 TRAIN" -Range $TimerangeTrain -FileName "${timestamp}_${Strategy}_train.json"
Invoke-Backtest -Stage "2/3 VALIDATION" -Range $TimerangeValidation -FileName "${timestamp}_${Strategy}_validation.json"
Invoke-Backtest -Stage "3/3 FINAL-TEST" -Range $TimerangeFinalTest -FileName "${timestamp}_${Strategy}_finaltest.json"

Write-Host "=== BACKTEST COMPLETADO ===" -ForegroundColor Green
Write-Host "Compara train vs validation vs final-test antes de iterar parametros." -ForegroundColor White
Write-Host "Si final-test cae fuerte, asume sobreoptimizacion." -ForegroundColor White

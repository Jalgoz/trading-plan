<#
.SYNOPSIS
Ejecuta backtest FreqAI vs baseline en train/validation/final-test.

.DESCRIPTION
Corre la estrategia FreqAI y la baseline sin ML en tres ventanas separadas:
1) Train: exploracion y ajuste inicial.
2) Validation: validacion intermedia.
3) Final-test: periodo intocable para decidir si descartar o avanzar.

Cada corrida usa `--enable-protections` para acercar el backtest al comportamiento
de dry-run/live cuando las protecciones estan definidas en la configuracion.

.PARAMETER Strategy
Estrategia ML a ejecutar (ej. FreqaiLightgbm).

.PARAMETER BaselineStrategy
Estrategia baseline para comparar en las mismas ventanas.

.PARAMETER TimerangeTrain
Ventana de exploracion inicial.

.PARAMETER TimerangeValidation
Ventana de validacion intermedia.

.PARAMETER TimerangeFinalTest
Ventana final intocable.

.PARAMETER Model
Modelo FreqAI a usar (ej. LightGBMClassifier).

.EXAMPLE
.\scripts\backtest_freqai.ps1

.NOTES
Si cambias features/target/config FreqAI, cambia `freqai.identifier` o limpia
`user_data/models/<identifier>` antes de interpretar resultados.
#>

param(
    [string]$Strategy = "FreqaiLightgbm",
    [string]$BaselineStrategy = "EmaCrossRsi",
    [string]$TimerangeTrain = "20220101-20231231",
    [string]$TimerangeValidation = "20240101-20240930",
    [string]$TimerangeFinalTest = "20241001-20250331",
    [string]$Model = "LightGBMClassifier"
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$exportDir = "/freqtrade/user_data/backtest_results"
$summaryDir = Join-Path $PSScriptRoot "..\progress\reports"
$summaryPath = Join-Path $summaryDir "freqai_vs_baseline_${timestamp}.md"

function Invoke-FreqaiBacktest {
    <#
    .SYNOPSIS
    Ejecuta una ventana de backtest FreqAI.
    #>
    param(
        [string]$Stage,
        [string]$Range,
        [string]$FileName
    )

    Write-Host "[$Stage] FreqAI $Strategy ($Range)..." -ForegroundColor Yellow
    docker compose run --rm freqtrade backtesting `
        --config /freqtrade/config/config-backtest-freqai.json `
        --strategy $Strategy `
        --freqaimodel $Model `
        --timerange $Range `
        --timeframe 1h `
        --enable-protections `
        --export trades `
        --export-filename "$exportDir/$FileName"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en backtest FreqAI etapa $Stage." -ForegroundColor Red
        exit 1
    }
}

function Invoke-BaselineBacktest {
    <#
    .SYNOPSIS
    Ejecuta una ventana de backtest baseline sin ML.
    #>
    param(
        [string]$Stage,
        [string]$Range,
        [string]$FileName
    )

    Write-Host "[$Stage] Baseline $BaselineStrategy ($Range)..." -ForegroundColor Yellow
    docker compose run --rm freqtrade backtesting `
        --config /freqtrade/config/config-backtest.json `
        --strategy $BaselineStrategy `
        --timerange $Range `
        --timeframe 1h `
        --enable-protections `
        --export trades `
        --export-filename "$exportDir/$FileName"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error en backtest baseline etapa $Stage." -ForegroundColor Red
        exit 1
    }
}

Write-Host "=== BACKTEST FreqAI vs Baseline ===" -ForegroundColor Cyan
Write-Host "Modelo: $Model" -ForegroundColor Yellow
Write-Host "Train: $TimerangeTrain" -ForegroundColor DarkCyan
Write-Host "Validation: $TimerangeValidation" -ForegroundColor DarkCyan
Write-Host "Final-test: $TimerangeFinalTest" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "ADVERTENCIA: FreqAI puede tardar 30-60+ minutos por ventana." -ForegroundColor Red
Write-Host "IMPORTANTE: Cambia freqai.identifier cuando cambies features/target/config." -ForegroundColor DarkYellow
Write-Host "Tip: descarga datos extra antes de cada timerange por train_period_days + startup_candle_count." -ForegroundColor DarkYellow
Write-Host ""

$runs = @(
    @{ Stage = "1/3 TRAIN"; Name = "train"; Range = $TimerangeTrain },
    @{ Stage = "2/3 VALIDATION"; Name = "validation"; Range = $TimerangeValidation },
    @{ Stage = "3/3 FINAL-TEST"; Name = "finaltest"; Range = $TimerangeFinalTest }
)

foreach ($run in $runs) {
    Invoke-FreqaiBacktest `
        -Stage $run.Stage `
        -Range $run.Range `
        -FileName "${timestamp}_${Strategy}_freqai_$($run.Name).json"

    Invoke-BaselineBacktest `
        -Stage $run.Stage `
        -Range $run.Range `
        -FileName "${timestamp}_${BaselineStrategy}_baseline_$($run.Name).json"

    Write-Host ""
}

if (-not (Test-Path $summaryDir)) {
    New-Item -ItemType Directory -Path $summaryDir | Out-Null
}

$summary = @(
    "# Resumen FreqAI vs Baseline",
    "",
    "- Fecha: $(Get-Date -Format \"yyyy-MM-dd HH:mm:ss\")",
    "- Estrategia ML: $Strategy ($Model)",
    "- Estrategia baseline: $BaselineStrategy",
    "- Protecciones: habilitadas con --enable-protections",
    "",
    "## Ventanas",
    "- Train: $TimerangeTrain",
    "- Validation: $TimerangeValidation",
    "- Final-test: $TimerangeFinalTest",
    "",
    "## Archivos exportados",
    "- FreqAI train: user_data/backtest_results/${timestamp}_${Strategy}_freqai_train.json",
    "- FreqAI validation: user_data/backtest_results/${timestamp}_${Strategy}_freqai_validation.json",
    "- FreqAI final-test: user_data/backtest_results/${timestamp}_${Strategy}_freqai_finaltest.json",
    "- Baseline train: user_data/backtest_results/${timestamp}_${BaselineStrategy}_baseline_train.json",
    "- Baseline validation: user_data/backtest_results/${timestamp}_${BaselineStrategy}_baseline_validation.json",
    "- Baseline final-test: user_data/backtest_results/${timestamp}_${BaselineStrategy}_baseline_finaltest.json",
    "",
    "## Checklist de decision",
    "- [ ] ML mejora algo medible contra baseline en validation",
    "- [ ] ML no se degrada fuerte en final-test",
    "- [ ] Drawdown ML <= baseline o esta justificado por mejor expectativa",
    "- [ ] Numero de trades suficiente (>= 100 ideal)",
    "- [ ] No hay senal de overfitting train -> validation -> final-test",
    "",
    "Si ML no mejora algo medible o falla en final-test, se descarta o vuelve a Fase 3."
)

$summary | Set-Content -Path $summaryPath -Encoding UTF8

Write-Host "=== BACKTEST FreqAI vs Baseline COMPLETADO ===" -ForegroundColor Green
Write-Host "Resumen: progress/reports/freqai_vs_baseline_${timestamp}.md" -ForegroundColor Gray

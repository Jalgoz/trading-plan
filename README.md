# Algo Trading Bot - Freqtrade + FreqAI (Binance Spot)

Bot de trading algoritmico con enfoque educativo y validacion por fases.

## Requisitos previos

- Docker Desktop instalado y corriendo
- Python 3.10+ (opcional, para notebook de Fase 2)
- Cuenta de Binance (sin dinero real hasta Fase 5)

## Estructura del proyecto

```text
trading-plan/
├── ARCHIVOS_CLAVE.md                # Orden sugerido de lectura del proyecto
├── INSTALL_FREQTRADE.md             # Instalacion y validacion Freqtrade/FreqAI
├── docker-compose.yml                 # Servicio base de Freqtrade
├── config/
│   ├── config-backtest.json           # Backtest estrategia baseline (Fase 1)
│   ├── config-backtest-freqai.json    # Backtest con FreqAI (Fase 3)
│   ├── config-dryrun.json             # Paper trading (Fase 4)
│   └── config-live.example.json       # Template para live (Fase 5)
├── strategies/
│   ├── EmaCrossRsi.py                 # Baseline sin ML
│   └── FreqaiLightgbm.py              # Estrategia con filtro ML
├── notebooks/
│   └── ml_fundamentals.ipynb          # Fundamentos ML para trading
├── scripts/
│   ├── download_data.ps1              # Descarga de datos OHLCV
│   ├── backtest.ps1                   # Backtest train/validation/final-test
│   ├── backtest_freqai.ps1            # Backtest FreqAI + resumen
│   ├── dryrun.ps1                     # Ejecuta paper trading
│   └── live.ps1                       # Ejecuta live con validaciones estrictas
├── progress/
│   ├── tracker.md                     # Checklist por fase
│   ├── journal.md                     # Diario tecnico de ejecucion
│   └── reports/                       # Generado al correr backtest_freqai.ps1
└── user_data/                         # Runtime-generated: datos/modelos/logs/resultados
```

## Inicio rapido (modo seguro, sin dinero real)

### 1) Inicializar `user_data`

```powershell
docker compose run --rm freqtrade create-userdir --userdir /freqtrade/user_data
```

### 2) Descargar datos historicos

```powershell
.\scripts\download_data.ps1
```

### 3) Backtest baseline (Fase 1)

```powershell
.\scripts\backtest.ps1
```

### 4) Backtest FreqAI (Fase 3)

```powershell
.\scripts\backtest_freqai.ps1
```

### 5) Paper trading obligatorio (Fase 4)

```powershell
.\scripts\dryrun.ps1
```

FreqUI: `http://localhost:8080`

## NO ejecutar live hasta cumplir esto

- [ ] Dry-run continuo minimo 8 semanas (ideal 12) con el mismo setup
- [ ] Minimo 50 trades en dry-run (ideal 100+) para tener muestra util
- [ ] Drawdown controlado (no supera 15%)
- [ ] Backtest y dry-run convergen (desviacion razonable, sin ruptura estructural)
- [ ] API de Binance sin permisos de retiro
- [ ] Telegram activo y alertas funcionando

## LIVE (seccion separada con riesgo real)

> ADVERTENCIA: `scripts/live.ps1` mueve dinero real. No es parte del flujo rapido normal.

1. Copiar `config/config-live.example.json` a `config/config-live.json`
2. Completar credenciales y secretos reales
3. Validar checklist anterior
4. Ejecutar:

```powershell
.\scripts\live.ps1
```

## Fases unificadas del plan

| Fase | Duracion | Objetivo |
|------|----------|----------|
| 0 | 3 semanas | Fundamentos de trading y riesgo (sin codigo) |
| 1 | 4 semanas | Baseline sin ML en Freqtrade |
| 2 | 5 semanas | Fundamentos de ML y validacion temporal |
| 3 | 6 semanas | FreqAI + comparacion contra baseline |
| 4 | 8-12 semanas | Paper trading (dry-run) con reglas duras |
| 5 | 6+ semanas | Trading real con micro-capital y apagado automatico |

Consulta `plan.md` y `progress/tracker.md` para criterios de paso y descarte.
Para recorrido de lectura sugerido, revisa `ARCHIVOS_CLAVE.md`.

## Notas de seguridad

- Nunca subas API keys a Git (`config/config-live.json` esta ignorado).
- API keys de Binance: solo trading, sin retiro.
- Empezar con $50-$100; el objetivo inicial es validar ejecucion real, no rentabilidad.

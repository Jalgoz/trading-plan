# Algo Trading Bot — Freqtrade + FreqAI (Binance Spot)

Bot de trading algorítmico con Machine Learning para crypto, usando Freqtrade y FreqAI.

## Requisitos previos

- **Docker Desktop** instalado y corriendo
- **Python 3.10+** (opcional, para notebooks de Fase 2)
- **Cuenta de Binance** (sin depositar dinero hasta Fase 5)

## Estructura del proyecto

```
algo-trading-bot/
├── docker-compose.yml              # Orquestación de Freqtrade + FreqUI
├── config/
│   ├── config-backtest.json        # Backtesting (Fase 1 y 3)
│   ├── config-dryrun.json          # Paper trading (Fase 4)
│   └── config-live.json            # Trading real (Fase 5)
├── strategies/
│   ├── EmaCrossRsi.py              # Fase 1: Estrategia sin ML
│   └── FreqaiLightgbm.py          # Fase 3: Estrategia con FreqAI
├── notebooks/
│   └── ml_fundamentals.ipynb       # Fase 2: Experimentación ML
├── scripts/
│   ├── download_data.ps1           # Descargar datos históricos
│   ├── backtest.ps1                # Ejecutar backtesting
│   ├── backtest_freqai.ps1         # Backtesting con FreqAI
│   ├── dryrun.ps1                  # Iniciar paper trading
│   └── live.ps1                    # Iniciar trading real
├── progress/
│   ├── tracker.md                  # Checklist por fase
│   └── journal.md                  # Diario de trading
└── user_data/                      # (creado por Freqtrade al iniciar)
    ├── data/                       # Datos OHLCV descargados
    ├── models/                     # Modelos FreqAI entrenados
    └── logs/                       # Logs del bot
```

## Inicio rápido

### 1. Inicializar Freqtrade user_data

```powershell
docker compose run --rm freqtrade create-userdir --userdir /freqtrade/user_data
```

### 2. Descargar datos históricos (1 año, 5 pares)

```powershell
.\scripts\download_data.ps1
```

### 3. Backtesting de estrategia simple (Fase 1)

```powershell
.\scripts\backtest.ps1
```

### 4. Backtesting con FreqAI (Fase 3)

```powershell
.\scripts\backtest_freqai.ps1
```

### 5. Paper trading (Fase 4)

```powershell
.\scripts\dryrun.ps1
```

FreqUI estará disponible en **http://localhost:8080** (user: `freqtrade`, pass: `freqtrade`)

### 6. Trading real (Fase 5 — SOLO después de paper trading exitoso)

1. Editar `config/config-live.json` con tus API keys de Binance
2. Ejecutar:
```powershell
.\scripts\live.ps1
```

## Fases del plan

| Fase | Duración | Descripción |
|------|----------|-------------|
| 0 | 3 sem | Fundamentos de trading (estudio, no código) |
| 1 | 4 sem | Freqtrade + estrategia EMA/RSI sin ML |
| 2 | 5 sem | Aprender ML desde cero |
| 3 | 6 sem | FreqAI — ML integrado en Freqtrade |
| 4 | 6 sem | Paper trading en vivo (dry-run) |
| 5 | 6+ sem | Trading real con micro-capital |

Consulta `progress/tracker.md` para el checklist detallado por fase.

## Notas de seguridad

- **NUNCA** subas API keys a Git. El `.gitignore` ya excluye `config-live.json`.
- Las API keys de Binance deben tener **solo permisos de trading**, NO de retiro.
- Empieza con **$50 USD**, no los $200 completos.

# Instalacion y Validacion de Freqtrade/FreqAI

Este documento instala y valida Freqtrade/FreqAI para este proyecto en dos modos:

- Docker (recomendado).
- Local nativo (Linux/WSL; en Windows puro no es la ruta recomendada).

Si vas a usar FreqAI con Docker, usa una imagen con dependencias FreqAI: `freqtradeorg/freqtrade:stable_freqai`.

## Requisitos

### Docker

- Docker Desktop o Docker Engine + docker compose plugin.
- Git.
- Este repositorio clonado localmente.

### Local nativo

- Python 3.11+.
- pip.
- git.
- virtualenv.
- TA-Lib / dependencias del sistema.
- Dependencias FreqAI (`requirements-freqai.txt`).

## Opcion recomendada: Docker

### Verificar compose

Abre `docker-compose.yml` y confirma:

```yaml
image: freqtradeorg/freqtrade:stable_freqai
ports:
  - "127.0.0.1:8080:8080"
```

### Crear `user_data`

```powershell
docker compose run --rm freqtrade create-userdir --userdir /freqtrade/user_data
```

### Verificar que Freqtrade/FreqAI arranca

```powershell
docker compose run --rm freqtrade -V
docker compose run --rm freqtrade list-strategies
docker compose run --rm freqtrade list-freqaimodels
```

### Ver configuracion efectiva

```powershell
docker compose run --rm freqtrade show-config --config /freqtrade/config/config-backtest.json --strategy EmaCrossRsi
docker compose run --rm freqtrade show-config --config /freqtrade/config/config-backtest-freqai.json --strategy FreqaiLightgbm --freqaimodel LightGBMClassifier
```

## Descargar datos historicos

```powershell
docker compose run --rm freqtrade download-data --config /freqtrade/config/config-backtest.json --pairs BTC/USDT ETH/USDT SOL/USDT --timeframes 1h 4h --timerange 20210101-
```

Nota FreqAI: descarga historia adicional antes del inicio real del backtest para cubrir `train_period_days`, `startup_candle_count` y timeframes incluidos.

## Backtest baseline

```powershell
docker compose run --rm freqtrade backtesting --config /freqtrade/config/config-backtest.json --strategy EmaCrossRsi --timerange 20220101-20250331 --timeframe 1h --enable-protections --export trades --export-filename /freqtrade/user_data/backtest_results/ema_baseline.json
```

## Backtest FreqAI

```powershell
docker compose run --rm freqtrade backtesting --config /freqtrade/config/config-backtest-freqai.json --strategy FreqaiLightgbm --freqaimodel LightGBMClassifier --timerange 20220101-20250331 --timeframe 1h --enable-protections --export trades --export-filename /freqtrade/user_data/backtest_results/freqai_lightgbm.json
```

## Dry-run

Baseline:

```powershell
docker compose run --rm -p 127.0.0.1:8080:8080 freqtrade trade --config /freqtrade/config/config-dryrun.json --strategy EmaCrossRsi
```

FreqAI:

```powershell
docker compose run --rm -p 127.0.0.1:8080:8080 freqtrade trade --config /freqtrade/config/config-dryrun.json --strategy FreqaiLightgbm --freqaimodel LightGBMClassifier
```

UI local: `http://127.0.0.1:8080`

En FreqAI, el reentrenamiento en dry/live ocurre dentro del comando `trade`, segun `identifier` y `live_retrain_hours`.

## Live

Preparar config real:

```powershell
copy config\config-live.example.json config\config-live.json
```

Editar:

- API key.
- API secret.
- `jwt_secret_key`.
- `ws_token`.
- `username`.
- `password`.
- Telegram.
- Bloque `freqai` si usaras `FreqaiLightgbm`.

Baseline live:

```powershell
docker compose run --rm -p 127.0.0.1:8080:8080 freqtrade trade --config /freqtrade/config/config-live.json --strategy EmaCrossRsi
```

FreqAI live:

```powershell
docker compose run --rm -p 127.0.0.1:8080:8080 freqtrade trade --config /freqtrade/config/config-live.json --strategy FreqaiLightgbm --freqaimodel LightGBMClassifier
```

## Instalacion local nativa

Ruta recomendada: Linux o WSL Ubuntu.

```bash
git clone https://github.com/freqtrade/freqtrade.git
cd freqtrade
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install -e .
pip install -r requirements-freqai.txt
freqtrade install-ui
freqtrade -V
freqtrade list-freqaimodels
```

Desde la raiz de este repo:

```bash
freqtrade show-config --config config/config-backtest.json --strategy EmaCrossRsi --strategy-path ./strategies
freqtrade backtesting --config config/config-backtest.json --strategy EmaCrossRsi --strategy-path ./strategies --timerange 20220101-20250331 --timeframe 1h --enable-protections
freqtrade backtesting --config config/config-backtest-freqai.json --strategy FreqaiLightgbm --strategy-path ./strategies --freqaimodel LightGBMClassifier --timerange 20220101-20250331 --timeframe 1h --enable-protections
```

## Actualizacion

Docker:

```powershell
docker compose pull
```

Instalacion nativa:

```bash
git pull
pip install -U -r requirements.txt
pip install -r requirements-freqai.txt
pip install -e .
freqtrade install-ui
```

## Validacion final minima

- `freqtrade -V` funciona.
- `freqtrade list-strategies` muestra tus estrategias.
- `freqtrade list-freqaimodels` muestra `LightGBMClassifier`.
- `show-config` resuelve sin errores.
- `download-data` completa sin errores.
- `backtesting` baseline completa.
- `backtesting` FreqAI completa.
- UI abre en `127.0.0.1:8080`.
- No expones el puerto a toda la red.

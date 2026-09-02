# Freqtrade — Free & Open Source Crypto Trading Bot

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/freqtrade)

> ⚠️ **Trading involves risk.** Freqtrade is educational software — always start in dry-run (paper trading) mode, which is the default in this template. Use at your own risk.

Freqtrade is a free, open source crypto trading bot written in Python supporting all major exchanges, controllable via a built-in web UI (FreqUI), REST API, or Telegram. This template deploys the official pinned Docker image (`freqtradeorg/freqtrade:2026.8`) pre-configured for Railway: FreqUI enabled on port 8080, persistent storage for strategies and databases, and safe dry-run defaults.

# Deploy and Host

Deploy with one click. On first boot the container seeds `/freqtrade/user_data` with a strategy skeleton and a safe default config (spot market, Kraken USD pairs, dry-run wallet of 1000 USD), then starts trading in dry-run mode. Persistent data (config, strategies, SQLite trade database, logs) lives on a Railway volume at `/freqtrade/user_data`.

## About Hosting

- Single service, official `freqtradeorg/freqtrade:2026.8` image — no source build
- Persistent Railway volume at `/freqtrade/user_data` (config, strategies, trades DB, logs)
- FreqUI + REST API served on port 8080 with HTTP basic auth (change the defaults!)
- All config values overridable via `FREQTRADE__` env vars (double underscore = nesting)
- Health-checked at `/api/v1/ping` (unauthenticated API endpoint)
- Runs in dry-run (paper trading) mode by default — no exchange keys needed

## Why Deploy

Self-hosting keeps your strategies, API keys, and trade data entirely under your control on infrastructure you own, with no third-party SaaS reading your trading activity. Railway adds persistent volumes, automatic restarts, one-click environment variable overrides, and zero server maintenance — deploy in under two minutes and iterate on strategies from the browser.

## Common Use Cases

- **Paper trading**: Validate strategies risk-free with the default dry-run configuration before committing funds
- **Live spot trading**: Add exchange API keys once your strategy proves itself in dry-run (Kraken by default — works worldwide including US; switch `FREQTRADE__EXCHANGE__NAME` to binance/kucoin/gate/okx if your region supports it)
- **Strategy development**: Hot-edit Python strategies in the mounted volume; the bot reloads them via the API or restart
- **24/7 unattended trading**: Railway keeps the bot running with automatic restarts and persistent trade history in SQLite
- **Telegram control**: Attach a Telegram bot to check profit, force entries/exits, and control the bot from your phone

## Dependencies for

**Public Dependencies:** None — everything runs in a single container with an embedded SQLite database on the attached volume.

**Private Dependencies:**
- A cryptocurrency exchange account (Kraken by default — dry-run works without keys)
- Telegram bot token (optional, for remote bot control)
- Exchange API key + secret (only for live trading, not dry-run)

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `FREQTRADE__API_SERVER__USERNAME` | `freqtrader` | FreqUI / REST API username |
| `FREQTRADE__API_SERVER__PASSWORD` | `change-me-please` | FreqUI / REST API password — CHANGE THIS |
| `FREQTRADE__API_SERVER__JWT_SECRET_KEY` | (random) | JWT signing secret for the API |
| `FREQTRADE__DRY_RUN` | `true` | Paper trading mode — keep `true` until strategy is proven |
| `FREQTRADE__DRY_RUN_WALLET` | `1000` | Simulated wallet balance |
| `FREQTRADE__STRATEGY` | `SampleStrategy` | Strategy class to run |
| `FREQTRADE__EXCHANGE__NAME` | `kraken` | Exchange (kraken, binance, kucoin, gate, okx...) |
| `FREQTRADE__EXCHANGE__KEY` / `__SECRET` | empty | Exchange API keys (live trading only) |
| `FREQTRADE__TELEGRAM__ENABLED` | `false` | Enable Telegram control bot |
| `FREQTRADE__TELEGRAM__TOKEN` / `__CHAT_ID` | empty | Telegram bot credentials |

Full configuration reference: [freqtrade.io/en/stable/configuration](https://www.freqtrade.io/en/stable/configuration/)

## Post-Deploy Setup

1. Open your Railway deployment URL — FreqUI loads at the root path
2. Log in with `FREQTRADE__API_SERVER__USERNAME` / `FREQTRADE__API_SERVER__PASSWORD`
3. Edit strategies under `user_data/strategies/` on the volume (or paste into FreqUI's strategy editor)
4. Set `FREQTRADE__STRATEGY` to your strategy class name and redeploy
5. When ready for live trading: add exchange keys + set `FREQTRADE__DRY_RUN=false`
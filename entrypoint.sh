#!/bin/sh
# Freqtrade Railway entrypoint:
# 1. seed /freqtrade/user_data on first boot (strategy skeleton + default config)
# 2. refresh config.json from the baked default each boot (env vars still
#    override at runtime via FREQTRADE__*); strategies/DB/logs persist
# 3. start `freqtrade trade` with env-var overrides applied via FREQTRADE__*
set -e

USERDIR="/freqtrade/user_data"

# Seed user_data on first boot (idempotent)
if [ ! -f "$USERDIR/strategies/sample_strategy.py" ]; then
  echo "[entrypoint] Seeding user_data..."
  mkdir -p "$USERDIR"
  # -n: do not overwrite existing files
  freqtrade create-userdir --userdir "$USERDIR" 2>&1 | grep -v "Could not chown" || true
fi

# Refresh config.json each boot: template updates (e.g. exchange changes)
# reach running services without requiring a volume reset. Strategies,
# DB and logs on the volume are untouched; FREQTRADE__* env vars still
# override values at runtime.
echo "[entrypoint] Refreshing config.json from template default..."
cp /freqtrade/config-default.json "$USERDIR/config.json"

echo "[entrypoint] Starting freqtrade trade..."
# python -m avoids the ftuser console-script shebang/user-site pitfalls when
# running as root; env-var overrides (FREQTRADE__*) still resolve
exec python3 -m freqtrade trade \
  --logfile "$USERDIR/logs/freqtrade.log" \
  --db-url "sqlite:///$USERDIR/tradesv3.sqlite" \
  --config "$USERDIR/config.json" \
  --strategy "${FREQTRADE__STRATEGY:-SampleStrategy}"
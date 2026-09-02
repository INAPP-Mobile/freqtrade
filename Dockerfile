# Freqtrade — free & open source crypto trading bot
# https://github.com/freqtrade/freqtrade (GPL-3.0)
# Wraps the official pinned image (freqtradeorg/freqtrade:2026.8) for Railway:
# - seeds /freqtrade/user_data on first boot (strategies skeleton + default config)
# - enables the REST API + bundled FreqUI on 0.0.0.0:8080
# - runs as root so the Railway-managed volume (root-owned) is writable
FROM freqtradeorg/freqtrade:2026.8

USER root

# freqtrade is pip user-installed under ftuser; root needs PYTHONPATH +
# HOME so python resolves the user-site packages and the console script.
ENV FREQTRADE__API_SERVER__ENABLED=true \
    FREQTRADE__API_SERVER__LISTEN_IP_ADDRESS=0.0.0.0 \
    FREQTRADE__API_SERVER__LISTEN_PORT=8080 \
    PYTHONPATH=/home/ftuser/.local/lib/python3.14/site-packages \
    HOME=/home/ftuser

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config-default.json /freqtrade/config-default.json
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

# /api/v1/ping is the unauthenticated Freqtrade API health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
  CMD python3 -c "import urllib.request,sys; r=urllib.request.urlopen('http://127.0.0.1:8080/api/v1/ping', timeout=5); sys.exit(0 if r.status==200 else 1)" || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
#!/usr/bin/env bash
set -euo pipefail

echo "[test.sh] Starting compose stack..."
docker compose up -d --build

echo "[test.sh] Waiting for services to report healthy..."
URLS=("http://localhost:8001/health" "http://localhost:8002/health" "http://localhost:8003/health")
for u in "${URLS[@]}"; do
  ok=false
  for i in {1..30}; do
    if curl -fsS "$u" >/dev/null 2>&1; then
      ok=true
      break
    fi
    sleep 2
  done
  if [ "$ok" = false ]; then
    echo "Service $u did not become healthy in time" >&2
    docker compose logs --tail 200
    exit 2
  fi
done

echo "[test.sh] Running pytest via sales-api-test..."
docker compose run --rm sales-api-test
code=$?

echo "[test.sh] Tearing down compose stack..."
docker compose down

exit $code

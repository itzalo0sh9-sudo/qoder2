#!/usr/bin/env bash
set -euo pipefail

# Wait for Postgres to be available
host=$(echo "$DATABASE_URL" | sed -E 's#.*@([^:/]+).*#\1#' || true)
port=$(echo "$DATABASE_URL" | sed -E 's#.*:([0-9]+)/.*#\1#' || true)

python - <<'PY'
import os, time, sys
try:
    import psycopg2
except Exception as e:
    print('psycopg2 not available:', e, file=sys.stderr)
    sys.exit(1)

dsn = os.getenv('DATABASE_URL')
if not dsn:
    print('DATABASE_URL not set', file=sys.stderr)
    sys.exit(1)

for i in range(60):
    try:
        conn = psycopg2.connect(dsn)
        conn.close()
        print('DB is ready')
        break
    except Exception:
        time.sleep(1)
else:
    print('Timed out waiting for authenticated DB', file=sys.stderr)
    sys.exit(1)
PY

# Run Alembic migrations if alembic is present
if [ -f ./alembic.ini ]; then
  echo "Running alembic upgrade head"
  alembic upgrade head || true
fi

exec "$@"

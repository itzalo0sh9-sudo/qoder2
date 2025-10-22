#!/usr/bin/env bash
set -euo pipefail

## Determine DSN: prefer HR_DATABASE_URL, fall back to DATABASE_URL
if [ -n "${HR_DATABASE_URL:-}" ]; then
    dsn_val="$HR_DATABASE_URL"
elif [ -n "${DATABASE_URL:-}" ]; then
    dsn_val="$DATABASE_URL"
else
    dsn_val=""
fi

if [ -n "$dsn_val" ]; then
    echo "Waiting for authenticated DB connection (hr) using HR_DATABASE_URL or DATABASE_URL"
    python - <<'PY'
import os, time, sys
from urllib.parse import urlparse
try:
        import psycopg2
except Exception as e:
        print('psycopg2 not available:', e, file=sys.stderr)
        sys.exit(1)

d = os.getenv('HR_DATABASE_URL') or os.getenv('DATABASE_URL')
if not d:
        print('No DSN available for hr', file=sys.stderr)
        sys.exit(1)

for i in range(60):
        try:
                conn = psycopg2.connect(d)
                conn.close()
                print('DB is ready')
                break
        except Exception:
                time.sleep(1)
else:
        print('Timed out waiting for authenticated DB', file=sys.stderr)
        sys.exit(1)

u = urlparse(d)
user = u.username or ''
pw = u.password or ''
host = u.hostname or ''
port = u.port or 5432
name = u.path.lstrip('/') or ''
print(f"export DB_USER={user}")
print(f"export DB_PASSWORD={pw}")
print(f"export DB_HOST={host}")
print(f"export DB_PORT={port}")
print(f"export DB_NAME={name}")
sys.exit(0)
PY
    eval "$(python - <<'PY'
from urllib.parse import urlparse
import os
d = os.getenv('HR_DATABASE_URL') or os.getenv('DATABASE_URL')
u = urlparse(d)
user = u.username or ''
pw = u.password or ''
host = u.hostname or ''
port = u.port or 5432
name = u.path.lstrip('/') or ''
print(f"export DB_USER={user}")
print(f"export DB_PASSWORD={pw}")
print(f"export DB_HOST={host}")
print(f"export DB_PORT={port}")
print(f"export DB_NAME={name}")
PY
    )"
fi

echo "Running Django migrations (hr)"
python manage.py migrate --noinput || true
exec "$@"

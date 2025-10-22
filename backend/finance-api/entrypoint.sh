#!/usr/bin/env bash
set -euo pipefail

## Determine DSN: prefer FINANCE_DATABASE_URL, fall back to DATABASE_URL
dsn_env_var=""
if [ -n "${FINANCE_DATABASE_URL:-}" ]; then
    dsn_env_var=FINANCE_DATABASE_URL
elif [ -n "${DATABASE_URL:-}" ]; then
    dsn_env_var=DATABASE_URL
fi

if [ -n "${!dsn_env_var:-}" ]; then
    echo "Waiting for authenticated DB connection (finance) using ${dsn_env_var}"
    python - <<'PY'
import os, time, sys
from urllib.parse import urlparse
try:
        import psycopg2
except Exception as e:
        print('psycopg2 not available:', e, file=sys.stderr)
        sys.exit(1)

env_name = os.getenv('dsn_env_var') or ''
d = os.getenv('FINANCE_DATABASE_URL') or os.getenv('DATABASE_URL')
if not d:
        print('No DSN available for finance', file=sys.stderr)
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

# parse and emit exports for Django settings to consume
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
    # evaluate the printed exports in the current shell
    eval "$(python - <<'PY'
from urllib.parse import urlparse
import os
d = os.getenv('FINANCE_DATABASE_URL') or os.getenv('DATABASE_URL')
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

echo "Running Django migrations (finance)"
python manage.py migrate --noinput || true
exec "$@"

#!/bin/bash

export HOME=/app
cd $HOME

DB_NAME="${DB_ENV_DB_NAME:-mike}"
DB_USER="${DB_ENV_DB_USER:-docker}"
DB_PASS="${DB_ENV_DB_PASS:-docker}"
DB_HOST="${DB_PORT_5432_TCP_ADDR}"
DB_PORT=${DB_PORT_5432_TCP_PORT}
REDIS_HOST="${REDIS_PORT_6379_TCP_ADDR:-$REDIS_HOST}"
REDIS_PORT=${REDIS_PORT_6379_TCP_PORT:-$REDIS_PORT}

read -d '' runner <<'EOF'
#!/bin/bash

set -e
export HOME=/app
hash -r
cd \$HOME

cat << CONF > supervisord.conf
[supervisord]
loglevel=debug
nodaemon=true
CONF

while read line
do
  if [[ "\$line" =~ ^([A-Za-z0-9_-]+):\s*(.+)$ ]]
  then
    name=\${line%%:*}
    command=\${line#*: }
    cat << CONF >> supervisord.conf
[program:\${name}]
command=/exec sh -c "\${command}"
autostart=true
autorestart=true
stopsignal=QUIT

CONF
  fi
done < "Procfile"

supervisord -c supervisord.conf
EOF

echo "$runner" | cat > $HOME/start
./start
#!/usr/bin/env bash
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "Waiting for network connectivity..."
for i in {1..60}; do
  if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/local-ipv4 >/dev/null; then
    echo "Network is up"
    break
  fi
  echo "Network not ready, retrying ($i/60)..."
  sleep 2
done

# Update & install OS packages (include AWS CLI & MySQL client)
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git jq python3 python3-pip python3-venv nginx curl unzip mysql-client

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Drop in the DB-check Python script (using PyMySQL)
WORK_DIR=/opt/webapp
mkdir -p "$WORK_DIR"
tee "$WORK_DIR/db_check.py" << 'EOF'
#!/usr/bin/env python3
import os
import sys
import json
import boto3
import pymysql
from botocore.config import Config

def get_db_creds():
    region = os.environ["AWS_REGION"]
    secret_id = os.environ["SECRET_ID"]
    cfg = Config(connect_timeout=5, read_timeout=10)
    client = boto3.client("secretsmanager", region_name=region, config=cfg)
    resp = client.get_secret_value(SecretId=secret_id)
    data = json.loads(resp["SecretString"])
    host = data["host"]
    port = int(data.get("port", 3306))
    return data["username"], data["password"], host, port, data["dbname"]

def main():
    try:
        user, pw, host, port, dbname = get_db_creds()
        conn = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=pw,
            database=dbname,
            connect_timeout=10
        )
        with conn.cursor() as cur:
            cur.execute("SELECT VERSION();")
            version = cur.fetchone()[0]
        print(f"DB version: {version}")
        sys.exit(0)
    except Exception as e:
        print(f"DB check failed: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF
chmod +x "$WORK_DIR/db_check.py"

# Install Python dependencies
python3 -m venv "$WORK_DIR/.venv"
source "$WORK_DIR/.venv/bin/activate"
pip3 install --no-cache-dir PyMySQL boto3

# Create status-render script
cat << 'SCRIPT' > "$WORK_DIR/webapp.sh"
#!/usr/bin/env bash

# Run DB check and capture output
if output=$("$WORK_DIR/.venv/bin/python" "$WORK_DIR/db_check.py" 2>&1); then
    STATUS="Online"
else
    STATUS="Offline"
fi

STATUS_HTML=/var/www/html/index.html
mkdir -p "$(dirname "$STATUS_HTML")"

tee "$STATUS_HTML" << EOF
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>DB Status</title></head>
<body style="font-family:sans-serif;text-align:center;padding:2rem;">
  <h1>Database Status</h1>
  <p style="font-size:2rem;">$STATUS</p>
  <p>Last update: $(date '+%Y-%m-%d %H:%M:%S %Z')</p>
  <pre>$output</pre>
</body>
</html>
EOF
SCRIPT
chmod +x "$WORK_DIR/webapp.sh"

# Configure Nginx to serve status page
tee /etc/nginx/sites-available/db_status << 'EOF'
server {
    listen 80;
    root /var/www/html;
    index index.html;
}
EOF
ln -sf /etc/nginx/sites-available/db_status /etc/nginx/sites-enabled/db_status
rm -f /etc/nginx/sites-enabled/default
systemctl enable nginx
systemctl restart nginx

# Cron job: run status update every 5 minutes
cat <<EOF > /etc/cron.d/webapp-db-check
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

AWS_REGION="${aws_region}"
DB_HOST="${db_host}"
SECRET_ID="${secret_id}"

# run DB check every 5 minutes
*/5 * * * * root $WORK_DIR/webapp.sh 2>&1
EOF
chown root:root /etc/cron.d/webapp-db-check
chmod 0644 /etc/cron.d/webapp-db-check

# Reload cron daemon and run initial status update
echo "Reloading cron..."
systemctl restart cron
$WORK_DIR/webapp.sh
echo "Webapp initialization complete."
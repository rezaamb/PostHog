#!/usr/bin/env bash

set -e

export DEBIAN_FRONTEND=noninteractive
export RESTART_MODE=l
export POSTHOG_APP_TAG="${POSTHOG_APP_TAG:-latest}"

POSTHOG_SECRET=$(head -c 28 /dev/urandom | sha224sum -b | head -c 56)
export POSTHOG_SECRET

ENCRYPTION_SALT_KEYS=$(openssl rand -hex 16)
export ENCRYPTION_SALT_KEYS

# 1. اطلاعات نسخه و دامنه را از کاربر بگیر
if ! [ -z "$1" ]; then
    export POSTHOG_APP_TAG=$1
else
    echo "What version of PostHog would you like to install? (default: latest)"
    read -r POSTHOG_APP_TAG_READ
    if [ -n "$POSTHOG_APP_TAG_READ" ]; then
        export POSTHOG_APP_TAG=$POSTHOG_APP_TAG_READ
    fi
fi

if ! [ -z "$2" ]; then
    export DOMAIN=$2
else
    echo "Enter your domain (ex: posthog.example.com):"
    read -r DOMAIN
    export DOMAIN=$DOMAIN
fi

# 2. نصب پیش‌نیازها
sudo apt update
sudo apt install -y git curl ca-certificates openssl docker.io docker-compose
sudo systemctl enable docker --now

# 3. کلون کردن ریپو و تنظیم نسخه
rm -rf posthog || true
git clone https://github.com/PostHog/posthog.git
cd posthog
if [[ "$POSTHOG_APP_TAG" != "latest" ]]; then
    git checkout "$POSTHOG_APP_TAG"
fi
cd ..

# 4. ساخت فایل env
cat > .env <<EOF
POSTHOG_SECRET=$POSTHOG_SECRET
ENCRYPTION_SALT_KEYS=$ENCRYPTION_SALT_KEYS
DOMAIN=$DOMAIN
EOF

# 5. ساخت docker-compose.yml (فقط سرویس‌های اصلی)
cat > docker-compose.yml <<EOF
version: "3.8"
services:
  posthog:
    image: posthog/posthog:\${POSTHOG_APP_TAG}
    restart: always
    environment:
      - DATABASE_URL=postgres://posthog:posthog@db:5432/posthog
      - REDIS_URL=redis://redis:6379
      - SECRET_KEY=\${POSTHOG_SECRET}
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis

  db:
    image: postgres:14
    restart: always
    environment:
      POSTGRES_USER: posthog
      POSTGRES_PASSWORD: posthog
      POSTGRES_DB: posthog
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:6
    restart: always
    volumes:
      - redisdata:/data

volumes:
  pgdata:
  redisdata:
EOF

# 6. بالا آوردن کانتینرها
docker-compose up -d --pull always

# 7. راهنمای بعد نصب
echo "\n✅ PostHog services are running on port 8000"
echo "🛡️ Now configure your HAProxy to reverse proxy https://$DOMAIN => http://localhost:8000"
echo "⚙️ Example HAProxy config will be provided separately."
echo "💾 To stop: docker-compose stop | To start: docker-compose start"
echo "✅ Installation completed!"

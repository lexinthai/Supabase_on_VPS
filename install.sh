#!/usr/bin/env bash
set -euo pipefail

# ----- 1. Предварительный опрос ----- 
read -p "Введите пожалуйста Ваш IP или домен: " IP_DOMAIN
read -p "Введите пожалуйста Ваш email для SSL: " EMAIL
read -p "Введите пожалуйста имя пользователя для входа: " DASH_USER
read -p "Введите пожалуйста пароль для входа: " DASH_PASS

if [ -z "$IP_DOMAIN" ]; then echo " Перепроверьте IP или домен пустой!"; exit 1; fi

# ----- 2. Системное обновление с установка зависимостей ----- 
apt update && apt upgrade -y
apt install -y curl git jq apache2-utils nginx certbot python3-certbot-nginx unzip 

# ----- 3. Тут установливаем Docker ----- 
curl -fsSL https://get.docker.com | sh

# ----- 4. Клонируем репозиторий Supabase из официального источника ----- 
cd ~
git clone https://github.com/supabase/supabase.git supabase-selfhost
cd supabase-selfhost/docker

# ----- 5. Генерируем .env конфигурационный файл----- 
cp .env.example .env
POSTGRES_PASS=$(openssl rand -hex 16)
JWT_SECRET=$(openssl rand -hex 20)
ANON_KEY=$(openssl rand -hex 20)
SERVICE_KEY=$(openssl rand -hex 20)
cat <<EOF >> .env
POSTGRES_PASSWORD=$POSTGRES_PASS
JWT_SECRET=$JWT_SECRET
ANON_KEY=$ANON_KEY
SERVICE_ROLE_KEY=$SERVICE_KEY
SITE_URL=https://$IP_DOMAIN
SUPABASE_PUBLIC_URL=https://$IP_DOMAIN
DASHBOARD_USERNAME=$DASH_USER
DASHBOARD_PASSWORD=$DASH_PASS
EOF

# ----- 6. Производим запуск Docker Compose ----- 
docker compose up -d

# ----- 7. Настраиваем сервер Nginx и Basic Auth ----- 
mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
htpasswd -bc /etc/nginx/.htpasswd $DASH_USER $DASH_PASS
cat <<EOL > /etc/nginx/sites-available/supabase
server {
    listen 80;
    server_name $IP_DOMAIN;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOL
ln -sf /etc/nginx/sites-available/supabase /etc/nginx/sites-enabled/supabase
nginx -t && systemctl restart nginx

# ----- 8. Запрашиваем выпуск SSL сертификата ----- 
certbot --nginx -d $IP_DOMAIN --agree-tos -m $EMAIL --redirect --non-interactive

# ----- 9. Производим настройку правил UFW (Файрвола) ----- 
# Выставляем запрет всех входящих и разрешаем все исходящие
ufw default deny incoming
ufw default allow outgoing
# Разрешить SSH, HTTP, HTTPS
ufw allow ssh
ufw allow http
ufw allow https
# Закрываем порты Supabase (54321–54324)
ufw deny proto tcp from any to any port 54321:54324
# Включаем Файрвол UFW без интерактивного подтверждения
ufw --force enable

# ----- 10. Итоговый завершающий вывод данных, необходимых для доступа ----- 
echo "
Установка Supabase на VPS завершена! Сначала скопируйте данные данные для входа, затем ПЕРЕЗАГРУЗИТЕ сервер!"
echo "  Dashboard: https://$IP_DOMAIN"
echo "  Username: $DASH_USER"
echo "  Password: $DASH_PASS"
echo "  Postgres password: $POSTGRES_PASS"
echo "  JWT_SECRET: $JWT_SECRET"
echo "  ANON_KEY: $ANON_KEY"
echo "  SERVICE_ROLE_KEY: $SERVICE_KEY"

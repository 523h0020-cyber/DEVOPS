#!/bin/bash
# Phase 3: SSL/HTTPS Setup with Let's Encrypt
# Prerequisites: phase2.sh must be completed first

set -euo pipefail

echo "================================================="
echo "🔐 BẮT ĐẦU PHASE 3: SSL & DOMAIN SETUP"
echo "================================================="

# Variables
DOMAIN="523h0020.site"
EMAIL="lenamgiang5@gmail.com"
NGINX_CONF="/etc/nginx/sites-available/midterm-app"
WEBROOT="/var/www/certbot"

# 1. Install Certbot for Let's Encrypt
echo "📦 [1/4] Đang cài đặt Certbot (Let's Encrypt)..."
apt-get install -y certbot python3-certbot-nginx

# 2. Create temporary HTTP-only Nginx config for ACME challenge validation
echo "🌐 [2/4] Đang tạo Nginx config tạm thời (HTTP only) cho ACME challenge..."
mkdir -p "$WEBROOT"
chown www-data:www-data "$WEBROOT"
chmod 755 "$WEBROOT"
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root $WEBROOT;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Verify and reload Nginx with temporary HTTP-only config
sudo nginx -t
sudo systemctl reload nginx

# 3. Get SSL Certificate from Let's Encrypt
echo "🔒 [3/4] Đang lấy SSL Certificate từ Let's Encrypt..."
echo "⚠️  Ensure your domain $DOMAIN is pointing to this server's IP before continuing!"
read -p "Press Enter to continue..."

sudo certbot certonly --webroot \
    --webroot-path "$WEBROOT" \
    --agree-tos \
    --non-interactive \
    --email $EMAIL \
    -d $DOMAIN \
    -d www.$DOMAIN

# Verify certificates were obtained before proceeding
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "❌ Certificate not found. Certbot may have failed. Aborting."
    exit 1
fi

# 4. Update Nginx config with full SSL configuration (certificates now exist)
echo "🌐 [4/4] Đang cập nhật Nginx với SSL cho domain $DOMAIN..."
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root $WEBROOT;
    }

    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Verify and reload Nginx with final SSL config
sudo nginx -t
sudo systemctl reload nginx

# 5. Setup Auto-renewal
echo "🔄 Đang cấu hình tự động gia hạn SSL Certificate..."
(crontab -l 2>/dev/null; echo "0 0 1 * * /usr/bin/certbot renew --quiet && systemctl reload nginx") | sudo crontab -

echo "================================================="
echo "✅ HOÀN TẤT PHASE 3! HTTPS đã bật cho $DOMAIN"
echo "🔐 Truy cập: https://$DOMAIN"
echo "📅 SSL Certificate sẽ tự động gia hạn trước khi hết hạn"
echo "================================================="

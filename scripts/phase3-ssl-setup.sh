#!/bin/bash
# Phase 3: SSL/HTTPS Setup with Let's Encrypt
# Prerequisites: phase2.sh must be completed first

set -e

echo "================================================="
echo "🔐 BẮT ĐẦU PHASE 3: SSL & DOMAIN SETUP"
echo "================================================="

# Variables
DOMAIN="523h0020.site"
EMAIL="lenamgiang5@gmail.com"
NGINX_CONF="/etc/nginx/sites-available/midterm-app"
PROJECT_DIR="/var/www/midterm-app"

# 1. Install Certbot for Let's Encrypt
echo "📦 [1/3] Đang cài đặt Certbot (Let's Encrypt)..."
apt-get install -y certbot python3-certbot-nginx

# 2. Update Nginx configuration with domain
echo "🌐 [2/3] Đang cập nhật Nginx với domain $DOMAIN..."
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    # SSL Certificate paths (will be updated by certbot)
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

# Verify and reload Nginx
sudo nginx -t
sudo systemctl restart nginx

# 3. Get SSL Certificate from Let's Encrypt
echo "🔒 [3/3] Đang lấy SSL Certificate từ Let's Encrypt..."
echo "⚠️  Ensure your domain $DOMAIN is pointing to this server's IP before continuing!"
read -p "Press Enter to continue..."

sudo certbot certonly --standalone \
    --agree-tos \
    --non-interactive \
    --email $EMAIL \
    -d $DOMAIN \
    -d www.$DOMAIN

# 4. Setup Auto-renewal
echo "🔄 Đang cấu hình tự động gia hạn SSL Certificate..."
echo "0 0 1 * * /usr/bin/certbot renew --quiet" | sudo crontab -

echo "================================================="
echo "✅ HOÀN TẤT PHASE 3! HTTPS đã bật cho $DOMAIN"
echo "🔐 Truy cập: https://$DOMAIN"
echo "📅 SSL Certificate sẽ tự động gia hạn trước khi hết hạn"
echo "================================================="

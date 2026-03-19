#!/bin/bash
# Phase 3: SSL/HTTPS Setup with Let's Encrypt

set -e

echo "================================================="
echo "🔐 BẮT ĐẦU PHASE 3: SSL & DOMAIN SETUP"
echo "================================================="

DOMAIN="523h0020.site"
EMAIL="lenamgiang5@gmail.com"
NGINX_CONF="/etc/nginx/sites-available/midterm-app"

# 1. Cài đặt Certbot và Nginx plugin
echo "📦 [1/3] Đang cài đặt Certbot (Let's Encrypt)..."
sudo apt-get install -y certbot python3-certbot-nginx

# 2. Cấu hình Nginx cơ bản (CHỈ CÓ PORT 80)
echo "🌐 [2/3] Đang cấu hình Nginx Port 80 cho domain $DOMAIN..."
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Kích hoạt Nginx cấu hình mới
sudo nginx -t
sudo systemctl restart nginx

# 3. Chạy Certbot (Nó sẽ tự động thêm cấu hình Port 443 vào file Nginx ở trên)
echo "🔒 [3/3] Đang xin cấp SSL và tự động cấu hình HTTPS..."
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email $EMAIL --redirect

# 4. Setup Auto-renewal
echo "🔄 Đang cấu hình tự động gia hạn SSL..."
(sudo crontab -l 2>/dev/null; echo "0 0 1 * * /usr/bin/certbot renew --quiet") | sudo crontab -

echo "================================================="
echo "✅ HOÀN TẤT PHASE 3! HTTPS đã bật cho $DOMAIN"
echo "================================================="
#!/bin/bash
# Phase 3: SSL/HTTPS Setup with Let's Encrypt
# Prerequisites: phase2.sh must be completed first

set -e

echo "================================================="
echo "🔐 BẮT ĐẦU PHASE 3: SSL & DOMAIN SETUP"
echo "================================================="
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "🔐 [PHASE 3] Đang cấu hình SSL cho $DOMAIN..."

sudo apt-get install -y certbot python3-certbot-nginx

# Chạy Certbot tự động (không tương tác)
sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL

# Tối ưu hóa Nginx sau khi có SSL (Security Headers)
sudo systemctl restart nginx

echo "✅ SSL đã được thiết lập thành công!"
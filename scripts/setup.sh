#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "🛠️ [PHASE 1] Đang cài đặt Runtime cho Ubuntu 24.04..."

sudo apt-get update -y
sudo apt-get install -y curl git ufw python3 python3-venv

# Cài Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Cài PM2 & Nginx
sudo npm install pm2@latest -g
sudo apt-get install -y nginx

# Tạo cấu trúc thư mục
sudo mkdir -p "$PROJECT_DIR/src" "$PROJECT_DIR/docs" "$PROJECT_DIR/scripts"
sudo chown -R $APP_USER:$APP_USER "$PROJECT_DIR"

echo "✅ Phase 1 Hoàn tất."
#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

echo "📦 [PHASE 2] Đang triển khai Code và MongoDB..."

# 1. Cài MongoDB (Nếu chưa có)
if ! command -v mongod &> /dev/null; then
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    sudo apt-get update -y && sudo apt-get install -y mongodb-org
    sudo systemctl enable --now mongod
fi

sleep 5

echo "🚚 Đang kéo code từ $REPO_URL (branch: $BRANCH)..."

# ✅ Quay về /tmp (safe, không phải working directory của phase2)
cd /tmp

# ✅ Xóa folder cũ (safe vì không ở trong nó)
sudo rm -rf "$PROJECT_DIR/src"

# ✅ Clone code
git clone -b "$BRANCH" "$REPO_URL" "$PROJECT_DIR/src"

# ✅ Vào ứng dụng
cd "$APP_DIR"
npm install

# 3. Cấu hình Nginx (Chỉ Port 80 để Certbot làm việc sau)
NGINX_CONF="/etc/nginx/sites-available/midterm-app"
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
echo "✅ Phase 2 Hoàn tất."
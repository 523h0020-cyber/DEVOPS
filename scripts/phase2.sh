#!/bin/bash

# phase2.sh - Phase 2 Traditional Deployment
# Installs DB, Pulls Code, Configures PM2 and Nginx

set -e

echo "================================================="
echo "🚀 BẮT ĐẦU PHASE 2: TRADITIONAL DEPLOYMENT"
echo "================================================="

# 1. Cài đặt MongoDB 8.0 cho Ubuntu 24.04 (Noble)
echo "🗄️ [1/4] Đang cài đặt MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update -y
sudo apt-get install -y mongodb-org
sudo systemctl enable --now mongod

# 2. Xóa src cũ và Clone lại Repository
PROJECT_DIR="/var/www/midterm-app"
REPO_URL="https://github.com/523h0020-cyber/DEVOPS.git"
echo "📦 [2/4] Đang kéo code mới nhất từ $REPO_URL..."

sudo rm -rf $PROJECT_DIR/src
sudo git clone $REPO_URL $PROJECT_DIR/src
APP_USER=${SUDO_USER:-$USER}
sudo chown -R $APP_USER:$APP_USER $PROJECT_DIR/src

# 3. Cài đặt Dependencies và Chạy với PM2
echo "⚙️ [3/4] Đang cài thư viện Node.js và bật PM2 cho app..."
# Đường dẫn chuẩn trong project của lệnh
APP_DIR="$PROJECT_DIR/src/sample-midterm-project/sample-midterm-node.js-project"
cd $APP_DIR

# Cài NPM packages
npm install

# Khởi động app qua PM2 (App nghe ở port 3000 theo main.js)
pm2 stop midterm-app || true # Dừng app cũ nếu có
pm2 start main.js --name "midterm-app"
pm2 save

# Khởi chạy PM2 cùng hệ thống (Tạo startup script)
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $APP_USER --hp /home/$APP_USER || true

# 4. Cấu hình Nginx Reverse Proxy
echo "🌐 [4/4] Đang cấu hình Nginx Reverse Proxy (Port 80 -> 3000)..."
NGINX_CONF="/etc/nginx/sites-available/midterm-app"
sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    server_name _;

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

# Kích hoạt Nginx site
sudo ln -sf /etc/nginx/sites-available/midterm-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

echo "================================================="
echo "✅ HOÀN TẤT PHASE 2! Ứng dụng đã được publish ra public IP!"
echo "Truy cập thông qua trình duyệt đê kiểm tra: http://<Public-IP>"
echo "================================================="

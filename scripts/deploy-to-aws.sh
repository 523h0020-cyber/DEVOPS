#!/bin/bash
set -e
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS_DIR/config.sh"

echo "🚀 [ORCHESTRATOR] Bắt đầu quy trình Deploy cho $DOMAIN"

# Bước 1: Setup môi trường (Phase 1)
if [ ! -d "$PROJECT_DIR" ]; then
    bash "$SCRIPTS_DIR/setup.sh"
fi

# Bước 2: Cài app & DB (Phase 2)
bash "$SCRIPTS_DIR/phase2.sh"

# Bước 3: DỌN DẸP PORT 3000 (Sử dụng file cleanup bạn vừa yêu cầu)
bash "$SCRIPTS_DIR/cleanup-port.sh"

# Bước 4: Chạy App bằng PM2
echo "▶️ Đang khởi động ứng dụng bằng PM2..."
cd "$APP_DIR"
pm2 start main.js --name "midterm-app"
pm2 save

# Tự động chạy lại khi reboot server
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $APP_USER --hp /home/$APP_USER || true

# Bước 5: Cài SSL (Phase 3)
read -p "Bạn có muốn cài đặt/cập nhật SSL ngay không? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    bash "$SCRIPTS_DIR/phase3-ssl-setup.sh"
fi

echo "✅ ĐÃ DEPLOY THÀNH CÔNG: https://$DOMAIN"
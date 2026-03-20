#!/bin/bash
# cleanup-port.sh - Dọn dẹp và Kiểm tra trạng thái Port 3000

# Load cấu hình để đồng bộ PORT (nếu bạn đã làm file config.sh như hướng dẫn trước)
# source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
TARGET_PORT=${APP_PORT:-3000} 

echo "🧹 [CLEANUP] Đang dọn dẹp triệt để Port $TARGET_PORT và PM2..."

# 1. Tắt PM2 ở cả User hiện tại và Root
pm2 delete all 2>/dev/null || true
sudo pm2 delete all 2>/dev/null || true

# 2. Tiêu diệt các tiến trình đang chiếm giữ port
# fuser -k sẽ gửi tín hiệu SIGKILL (-9) đến các process đang mở port
sudo fuser -k -9 $TARGET_PORT/tcp 2>/dev/null || true

# 3. Đợi một chút để OS cập nhật bảng trạng thái network
sleep 2

# 4. BƯỚC KIỂM TRA QUAN TRỌNG
# Kiểm tra xem có tiến trình nào còn sót lại trên port không
CHECK_PORT=$(sudo lsof -t -i:$TARGET_PORT)

if [ -z "$CHECK_PORT" ]; then
    # Nếu biến CHECK_PORT rỗng nghĩa là không có tiến trình nào
    echo "✅ [CLEANUP] Port $TARGET_PORT đã được giải phóng hoàn toàn!"
else
    # Nếu vẫn còn PID xuất hiện
    echo "❌ [ERROR] Cổng $TARGET_PORT vẫn đang bị chiếm bởi các tiến trình sau:"
    sudo lsof -i:$TARGET_PORT
    echo "⚠️  Không thể giải phóng cổng. Quá trình deploy sẽ dừng lại để tránh xung đột."
    exit 1 # Thoát script với mã lỗi để deploy-to-aws.sh không chạy tiếp
fi
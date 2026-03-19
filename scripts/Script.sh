#!/bin/bash

# Lệnh này giúp script tự động dừng lại nếu có bất kỳ lỗi nào xảy ra
set -e

echo "========================================"
echo "🚀 BẮT ĐẦU CÀI ĐẶT MÔI TRƯỜNG MÁY CHỦ 🚀"
echo "========================================"

# 1. Cập nhật hệ điều hành
echo "🔄 [1/5] Đang cập nhật các gói phần mềm của Ubuntu..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Cài đặt các công cụ cơ bản
echo "📦 [2/5] Đang cài đặt curl, git, và firewall (ufw)..."
sudo apt-get install -y curl git ufw

# 3. Cài đặt Node.js (Phiên bản LTS 20.x)
echo "🟢 [3/5] Đang cài đặt Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4. Cài đặt PM2 (Công cụ giữ cho app luôn chạy ở Phase 2)
echo "⚙️ [4/5] Đang cài đặt PM2 (Process Manager)..."
sudo npm install pm2@latest -g

# 5. Cài đặt Nginx (Reverse Proxy)
echo "🌐 [5/5] Đang cài đặt Nginx..."
sudo apt-get install -y nginx

# (Tùy chọn) Khởi tạo thư mục chứa project
echo "📂 Đang tạo thư mục /var/www/midterm-project..."
sudo mkdir -p /var/www/midterm-project
sudo chown -R $USER:$USER /var/www/midterm-project

echo "========================================"
echo "✅ CÀI ĐẶT THÀNH CÔNG MỌI DEPENDENCIES!"
echo "👉 Kiểm tra phiên bản các công cụ:"
node -v
npm -v
pm2 -v
nginx -v
echo "========================================"
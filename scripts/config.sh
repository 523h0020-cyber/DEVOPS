#!/bin/bash
# config.sh - Nơi lưu trữ toàn bộ biến cấu hình của dự án

# 1. Thông tin Domain & SSL
export DOMAIN="523h0020.site"
export EMAIL="lenamgiang5@gmail.com"

# 2. Thông tin Source Code
export REPO_URL="https://github.com/523h0020-cyber/DEVOPS.git"
export BRANCH="feature/setup-scripts" # Branch để deploy

# 3. Đường dẫn thư mục (Paths)
export PROJECT_DIR="/var/www/midterm-app"
# Cập nhật đường dẫn chính xác tới nơi chứa package.json
export APP_DIR="$PROJECT_DIR/src/sample-midterm-project/sample-midterm-node.js-project" 

# 4. Ứng dụng & Môi trường
export APP_PORT="3000"
export APP_USER="${SUDO_USER:-$USER}" # Tự động lấy user hiện tại (ví dụ: ubuntu)
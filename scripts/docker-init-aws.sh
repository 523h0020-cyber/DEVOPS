#!/bin/bash
# Docker Setup Initialization
# Run once on AWS server to prepare for Docker deployment

set -e

echo "=================================================="
echo "🐳 DOCKER INITIALIZATION (AWS Server)"
echo "=================================================="
echo ""

# 1. Check OS
echo "1️⃣  Checking system..."
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "⚠️  This script is optimized for Ubuntu"
fi
echo "✅ Running on: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
echo ""

# 2. Install Docker if needed
echo "2️⃣  Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed: $(docker --version)"
fi
echo ""

# 3. Install Docker Compose if needed
echo "3️⃣  Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed: $(docker-compose --version)"
fi
echo ""

# 4. Add ubuntu user to docker group
echo "4️⃣  Configuring docker group..."
if ! groups ubuntu | grep -q docker; then
    sudo usermod -aG docker ubuntu
    echo "✅ ubuntu user added to docker group (restart shell to apply)"
else
    echo "✅ ubuntu user already in docker group"
fi
echo ""

# 5. Create app directories
echo "5️⃣  Creating app directories..."
sudo mkdir -p /var/www/midterm-app
sudo mkdir -p /var/lib/midterm-app/mongodb
sudo mkdir -p /var/www/midterm-app/public/uploads
sudo mkdir -p /var/www/midterm-app/logs
sudo mkdir -p /var/www/midterm-app/backups
sudo chown -R ubuntu:ubuntu /var/www/midterm-app
sudo chown -R ubuntu:ubuntu /var/lib/midterm-app
echo "✅ Directories created"
echo ""

# 6. Create .env.docker file
echo "6️⃣  Creating environment file..."
cat > /var/www/midterm-app/.env.docker <<'EOF'
# Docker environment variables
NODE_ENV=production
PORT=3000
MONGO_URI=mongodb://mongodb:27017/products_db
DOCKER_HUB_USERNAME=your-docker-hub-username
IMAGE_VERSION=1.0.0
EOF
echo "✅ .env.docker created"
echo "   Please edit: nano /var/www/midterm-app/.env.docker"
echo ""

# 7. Create docker-compose.yml tracker
echo "7️⃣  Checking docker-compose.yml..."
if [ ! -f "/var/www/midterm-app/docker-compose.yml" ]; then
    echo "⚠️  docker-compose.yml not found in /var/www/midterm-app"
    echo "   Copy it from git repo or transfer from local machine"
else
    echo "✅ docker-compose.yml found"
fi
echo ""

# 8. Test Docker daemon
echo "8️⃣  Testing Docker daemon..."
if docker ps >/dev/null 2>&1; then
    echo "✅ Docker daemon running"
else
    echo "❌ Docker daemon error"
    echo "   Try: sudo systemctl restart docker"
    exit 1
fi
echo ""

# 9. Check disk space
echo "9️⃣  Checking disk space..."
DISK_FREE=$(df -BG /var | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$DISK_FREE" -lt 10 ]; then
    echo "⚠️  Low disk space: ${DISK_FREE}GB free"
else
    echo "✅ Disk space: ${DISK_FREE}GB free"
fi
echo ""

# 10. Show next steps
echo "=================================================="
echo "✅ INITIALIZATION COMPLETE!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Edit environment: nano /var/www/midterm-app/.env.docker"
echo "2. Copy docker-compose.yml to /var/www/midterm-app/"
echo "3. Navigate: cd /var/www/midterm-app"
echo "4. Deploy: bash scripts/docker-deploy.sh"
echo ""
echo "Verify setup:"
echo "  docker ps          # Show containers"
echo "  docker images      # Show images"
echo "  docker version     # Show versions"
echo ""

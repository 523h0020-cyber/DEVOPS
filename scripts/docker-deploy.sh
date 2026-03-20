#!/bin/bash
# Docker Compose Deployment Script
# Run on AWS server to start containerized application

set -e

echo "=================================================="
echo "🐳 DOCKER COMPOSE DEPLOYMENT"
echo "=================================================="
echo ""

# 1. Check prerequisites
echo "1️⃣  Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed"
    exit 1
fi
echo "✅ Docker: $(docker --version)"

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not installed"
    exit 1
fi
echo "✅ Docker Compose: $(docker-compose --version)"
echo ""

# 2. Create directories for volumes
echo "2️⃣  Creating directories..."
sudo mkdir -p /var/lib/midterm-app/mongodb
sudo mkdir -p /var/www/midterm-app/uploads
sudo mkdir -p /var/www/midterm-app/logs
sudo mkdir -p /var/www/midterm-app/backups
echo "✅ Directories created"
echo ""

# 3. Copy docker-compose.yml
echo "3️⃣  Checking docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found"
    exit 1
fi
echo "✅ docker-compose.yml found"
echo ""

# 4. Set environment variables
echo "4️⃣  Loading environment..."
if [ -f ".env.docker" ]; then
    export $(cat .env.docker | grep -v '#' | xargs)
    echo "✅ .env.docker loaded"
else
    echo "⚠️  .env.docker not found, using defaults"
fi
echo ""

# 5. Pull latest images
echo "5️⃣  Pulling images from registry..."
docker-compose pull
echo "✅ Images pulled"
echo ""

# 6. Start containers
echo "6️⃣  Starting containers..."
docker-compose up -d
echo "✅ Containers started"
echo ""

# 7. Wait for services to be healthy
echo "7️⃣  Waiting for services to be ready..."
sleep 10
echo "✅ Services should be ready"
echo ""

# 8. Show status
echo "8️⃣  Service status:"
docker-compose ps
echo ""

# 9. Health checks
echo "9️⃣  Health checks:"

# MongoDB health
if docker exec mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
    echo "✅ MongoDB: HEALTHY"
else
    echo "⚠️  MongoDB: Initializing..."
fi

# Web app health
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Web App: HEALTHY"
else
    echo "⚠️  Web App: Starting..."
fi
echo ""

# 10. Show logs
echo "🔟 Recent logs:"
docker-compose logs --tail=20 web
echo ""

echo "=================================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=================================================="
echo ""
echo "Commands:"
echo "  View logs:     docker-compose logs -f"
echo "  Stop:          docker-compose stop"
echo "  Restart:       docker-compose restart"
echo "  Remove:        docker-compose down"
echo "  Access app:    curl http://localhost:3000"
echo "  Mongodb shell: docker exec -it mongodb mongosh"
echo ""

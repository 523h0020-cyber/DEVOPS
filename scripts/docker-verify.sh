#!/bin/bash
# Verify Docker setup and deployment
# Run on AWS server after docker-compose up -d

set -e

echo "=================================================="
echo "✅ DOCKER DEPLOYMENT VERIFICATION"
echo "=================================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# 1. Check Docker
echo "1️⃣  Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✅ $DOCKER_VERSION${NC}"
else
    echo -e "${RED}❌ Docker not installed${NC}"
    exit 1
fi
echo ""

# 2. Check Docker Compose
echo "2️⃣  Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✅ $COMPOSE_VERSION${NC}"
else
    echo -e "${RED}❌ Docker Compose not installed${NC}"
    exit 1
fi
echo ""

# 3. Check containers running
echo "3️⃣  Checking running containers..."
docker-compose ps
echo ""

# 4. Check MongoDB health
echo "4️⃣  Checking MongoDB..."
if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
    DB_COUNT=$(docker-compose exec -T mongodb mongosh --eval "use products_db; print(db.products.countDocuments())" | grep -oP '\d+$' || echo "unknown")
    echo -e "${GREEN}✅ MongoDB healthy (Products: $DB_COUNT)${NC}"
else
    echo -e "${YELLOW}⚠️  MongoDB initializing...${NC}"
fi
echo ""

# 5. Check web app
echo "5️⃣  Checking web application..."
if curl -s http://localhost:3000 | grep -q "<!DOCTYPE html" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Web app responding (HTML received)${NC}"
else
    echo -e "${YELLOW}⚠️  Web app may be initializing...${NC}"
fi
echo ""

# 6. Check Nginx
echo "6️⃣  Checking Nginx..."
if sudo systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Nginx running${NC}"
else
    echo -e "${RED}❌ Nginx not running${NC}"
fi
echo ""

# 7. Check port bindings
echo "7️⃣  Checking port bindings..."
PORTS=$(netstat -tlnp 2>/dev/null | grep LISTEN | grep -E ':(80|443|3000|27017)' || true)
if [ ! -z "$PORTS" ]; then
    echo "$PORTS" | awk '{print "  " $0}'
else
    echo -e "${YELLOW}⚠️  Some ports may not be visible (might need sudo)${NC}"
fi
echo ""

# 8. Check volumes
echo "8️⃣  Checking volumes..."
VOLUMES=$(docker volume ls | grep midterm || echo "")
if [ ! -z "$VOLUMES" ]; then
    echo "$VOLUMES"
    echo -e "${GREEN}✅ Volumes created${NC}"
else
    echo -e "${YELLOW}⚠️  No Docker volumes found${NC}"
fi
echo ""

# 9. Check disk usage
echo "9️⃣  Checking disk usage..."
docker system df
echo ""

# 10. Show logs
echo "🔟 Recent logs:"
echo "  MongoDB:"
docker-compose logs --tail=5 mongodb 2>/dev/null | head -5
echo "  Web app:"
docker-compose logs --tail=5 web 2>/dev/null | head -5
echo ""

# 11. Show commands for next steps
echo "=================================================="
echo "📚 USEFUL COMMANDS"
echo "=================================================="
echo ""
echo "View logs:"
echo "  docker-compose logs -f            # All services"
echo "  docker-compose logs -f web        # Web app only"
echo "  docker-compose logs -f mongodb    # MongoDB only"
echo ""
echo "Database:"
echo "  docker-compose exec mongodb mongosh"
echo ""
echo "Execute in web container:"
echo "  docker-compose exec web bash"
echo "  docker-compose exec web npm test"
echo ""
echo "Management:"
echo "  docker-compose ps                 # Status"
echo "  docker-compose restart            # Restart all"
echo "  docker-compose stop               # Stop (graceful)"
echo "  docker-compose down               # Remove containers"
echo ""
echo "Backup & Restore:"
echo "  ./docker-manage.sh backup         # Backup MongoDB"
echo "  ./docker-manage.sh restore FILE   # Restore from backup"
echo ""
echo "Health check:"
echo "  ./docker-manage.sh health"
echo ""

echo "=================================================="
echo "✅ VERIFICATION COMPLETE!"
echo "=================================================="
echo ""

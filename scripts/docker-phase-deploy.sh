#!/bin/bash
# Full Docker Phase Deployment
# Complete setup: Build → Push → Deploy → Configure Nginx

set -e

DOCKER_HUB_USERNAME="${1:-your-docker-hub-username}"
IMAGE_TAG="${2:-1.0.0}"

echo "=================================================="
echo "🐳 DOCKER PHASE - COMPLETE DEPLOYMENT"
echo "=================================================="
echo ""
echo "Docker Hub Username: $DOCKER_HUB_USERNAME"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Determine if running locally or on AWS
if [ "$HOSTNAME" = "ip-172-31-"* ] || [ -f "/var/www/midterm-app/docker-compose.yml" ]; then
    echo "🔍 Detected AWS environment"
    IS_AWS=true
else
    echo "🔍 Detected local environment"
    IS_AWS=false
fi
echo ""

# Phase 1: Build (only on local machine)
if [ "$IS_AWS" = false ]; then
    echo "=================================================="
    echo "PHASE 1: Build Docker Image"
    echo "=================================================="
    
    bash scripts/docker-build-push.sh $DOCKER_HUB_USERNAME $IMAGE_TAG
    
    if [ $? -ne 0 ]; then
        echo "❌ Build failed"
        exit 1
    fi
    echo ""
else
    echo "⏭️  Skipping build phase (on AWS server)"
    echo ""
fi

# Phase 2: Deploy (on AWS)
if [ "$IS_AWS" = true ]; then
    echo "=================================================="
    echo "PHASE 2: Deploy Docker Containers"
    echo "=================================================="
    
    bash scripts/docker-deploy.sh
    
    if [ $? -ne 0 ]; then
        echo "❌ Deployment failed"
        exit 1
    fi
    echo ""
    
    # Phase 3: Configure Nginx
    echo "=================================================="
    echo "PHASE 3: Configure Nginx Proxy"
    echo "=================================================="
    
    bash scripts/docker-nginx-proxy.sh
    
    if [ $? -ne 0 ]; then
        echo "❌ Nginx configuration failed"
        exit 1
    fi
    echo ""
else
    echo "📝 Next steps on AWS server:"
    echo "1. scp docker-compose.yml ubuntu@44.207.47.147:/tmp/"
    echo "2. ssh ubuntu@44.207.47.147"
    echo "3. mkdir -p /var/www/midterm-app && cd /var/www/midterm-app"
    echo "4. cp /tmp/docker-compose.yml ."
    echo "5. bash scripts/docker-deploy.sh"
    echo "6. bash scripts/docker-nginx-proxy.sh"
    echo ""
fi

echo "=================================================="
echo "✅ DOCKER PHASE COMPLETE!"
echo "=================================================="
echo ""
echo "Summary:"
echo "  - Docker image: ${DOCKER_HUB_USERNAME}/midterm-app:${IMAGE_TAG}"
echo "  - Services:"
echo "    • web (Node.js app on port 3000)"
echo "    • mongodb (Database on port 27017)"
echo "  - Nginx: Proxying TCP 80/443 → Docker container"
echo "  - Volumes: Persistent data storage"
echo ""
echo "Testing:"
echo "  curl http://localhost:3000"
echo "  curl https://523h0020.site"
echo ""

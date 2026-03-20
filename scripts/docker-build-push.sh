#!/bin/bash
# Docker Build & Push Script
# Build multi-stage image and push to Docker Hub

set -e

# Configuration
DOCKER_HUB_USERNAME="${1:-your-docker-hub-username}"
IMAGE_NAME="midterm-app"
IMAGE_TAG="${2:-latest}"
REGISTRY="${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "=================================================="
echo "🐳 DOCKER BUILD & PUSH"
echo "=================================================="
echo ""
echo "Image: $REGISTRY"
echo ""

# 1. Navigate to app directory
APP_DIR="sample-midterm-project/sample-midterm-node.js-project"
if [ ! -d "$APP_DIR" ]; then
    echo "❌ App directory not found: $APP_DIR"
    exit 1
fi

cd $APP_DIR
echo "✅ In app directory: $PWD"
echo ""

# 2. Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not installed"
    exit 1
fi
echo "✅ Docker found: $(docker --version)"
echo ""

# 3. Build image (multi-stage)
echo "🔨 Building image (multi-stage build)..."
docker build \
  --tag $REGISTRY \
  --tag ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest \
  --label version="$IMAGE_TAG" \
  --label timestamp="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  .

echo "✅ Image built successfully"
echo ""

# 4. Show image info
echo "📊 Image information:"
docker images | grep $IMAGE_NAME | head -1
echo ""

# 5. Test image locally (optional)
echo "🧪 Testing image..."
docker run --rm $REGISTRY node --version
echo "✅ Image test passed"
echo ""

# 6. Login to Docker Hub
echo "🔑 Docker Hub login (if needed)..."
if [ -n "$DOCKER_HUB_TOKEN" ]; then
    echo $DOCKER_HUB_TOKEN | docker login -u $DOCKER_HUB_USERNAME --password-stdin
else
    echo "⚠️  Skipping login (no token provided)"
fi
echo ""

# 7. Push to Docker Hub
echo "⬆️  Pushing to Docker Hub..."
docker push $REGISTRY
docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest
echo "✅ Image pushed successfully"
echo ""

# 8. Show next steps
echo "=================================================="
echo "✅ BUILD & PUSH COMPLETE!"
echo "=================================================="
echo ""
echo "Image URL: $REGISTRY"
echo ""
echo "Next steps:"
echo "1. Update docker-compose.yml with image: $REGISTRY"
echo "2. On AWS server, run: docker-compose pull"
echo "3. Then: docker-compose up -d"
echo ""

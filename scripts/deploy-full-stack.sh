#!/bin/bash
# Complete Midterm App Deployment with Docker
# Orchestrates all phases: Phase 1 (Nginx/Node) → Phase 2 (MongoDB) → Phase 3 (Docker)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_banner() {
    cat <<EOF
${BLUE}
╔════════════════════════════════════════════════════════════╗
║  🚀 MIDTERM APP - COMPLETE DEPLOYMENT ORCHESTRATOR 🚀     ║
║                                                            ║
║  Phases:                                                   ║
║  1️⃣  Infrastructure Setup (Node.js, Nginx)                ║
║  2️⃣  Database Setup (MongoDB)                             ║
║  3️⃣  Containerization (Docker, Docker Compose)            ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
${NC}
EOF
}

show_usage() {
    cat <<EOF
Usage: deploy-full-stack.sh [PHASE] [OPTIONS]

Phases:
  all         Deploy all phases (1, 2, 3)
  1           Phase 1: Infrastructure setup
  2           Phase 2: Database setup
  3           Phase 3: Docker containerization
  local       Test build locally (build & verify Docker image)
  
Options:
  --docker-user USERNAME    Docker Hub username
  --image-tag TAG          Image version (default: 1.0.0)
  --skip-ssl               Skip SSL setup
  --dry-run                Show commands without executing
  
Examples:
  ./deploy-full-stack.sh all --docker-user myname
  ./deploy-full-stack.sh 3 --image-tag 1.0.1
  ./deploy-full-stack.sh local

Environment Setup:
  Export on AWS server before running:
  export DOCKER_HUB_USERNAME=your-username
  export IMAGE_TAG=1.0.0
EOF
}

# Parse arguments
PHASE="${1:-help}"
DOCKER_USER="${DOCKER_HUB_USERNAME:-${2}}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"
SKIP_SSL=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --docker-user)
            DOCKER_USER="$2"
            shift 2
            ;;
        --image-tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --skip-ssl)
            SKIP_SSL=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [ "$PHASE" = "help" ]; then
    show_usage
    exit 0
fi

show_banner

echo "Configuration:"
echo "  Phase: $PHASE"
echo "  Docker Hub: $DOCKER_USER"
echo "  Image Tag: $IMAGE_TAG"
echo "  Skip SSL: $SKIP_SSL"
echo "  Dry Run: $DRY_RUN"
echo ""

# Determine environment
if [ "$HOSTNAME" = "ip-172-31-"* ] || [ -f "/var/www/midterm-app/main.js" ]; then
    ENV="aws"
    echo -e "${YELLOW}🔍 AWS Environment Detected${NC}"
else
    ENV="local"
    echo -e "${YELLOW}🔍 Local Environment Detected${NC}"
fi
echo ""

# Phase 1: Infrastructure
run_phase_1() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Phase 1️⃣  Infrastructure Setup${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ "$ENV" = "aws" ]; then
        echo "Setting up infrastructure..."
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: bash scripts/setup.sh"
        else
            bash scripts/setup.sh
        fi
    else
        echo "⏭️  Skipping Phase 1 (local environment)"
    fi
    echo ""
}

# Phase 2: Database
run_phase_2() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Phase 2️⃣  Database Setup${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ "$ENV" = "aws" ]; then
        echo "Setting up MongoDB and deploying application..."
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: bash scripts/phase2.sh"
        else
            bash scripts/phase2.sh
        fi
    else
        echo "⏭️  Skipping Phase 2 (local environment)"
    fi
    echo ""
}

# Phase 3: Docker
run_phase_3() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Phase 3️⃣  Docker Containerization${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ -z "$DOCKER_USER" ]; then
        echo -e "${RED}❌ Docker Hub username required${NC}"
        echo "   Use: --docker-user your-username"
        exit 1
    fi
    
    if [ "$ENV" = "aws" ]; then
        echo "Deploying Docker containers..."
        
        # Initialize Docker
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: bash scripts/docker-init-aws.sh"
        else
            bash scripts/docker-init-aws.sh
        fi
        
        # Deploy containers
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: bash scripts/docker-deploy.sh"
        else
            bash scripts/docker-deploy.sh
        fi
        
        # Configure Nginx
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: bash scripts/docker-nginx-proxy.sh"
        else
            bash scripts/docker-nginx-proxy.sh
        fi
        
        # Verify
        if [ "$DRY_RUN" = false ]; then
            echo ""
            echo "Verifying deployment..."
            bash scripts/docker-verify.sh
        fi
    else
        echo "Building Docker image locally..."
        if [ "$DRY_RUN" = true ]; then
            echo "DRY RUN: cd sample-midterm-project/sample-midterm-node.js-project"
            echo "DRY RUN: docker build -t $DOCKER_USER/midterm-app:$IMAGE_TAG ."
        else
            cd sample-midterm-project/sample-midterm-node.js-project
            docker build -t $DOCKER_USER/midterm-app:$IMAGE_TAG .
            cd ../../
            echo ""
            echo "✅ Image built: $DOCKER_USER/midterm-app:$IMAGE_TAG"
            echo ""
            echo "Next: Push to Docker Hub"
            echo "  docker push $DOCKER_USER/midterm-app:$IMAGE_TAG"
        fi
    fi
    echo ""
}

# Local test build
run_local_test() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Local Test Build${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ -z "$DOCKER_USER" ]; then
        echo -e "${RED}❌ Docker Hub username required${NC}"
        exit 1
    fi
    
    echo "Testing Docker build locally..."
    
    cd sample-midterm-project/sample-midterm-node.js-project
    
    echo "1️⃣  Building image..."
    if docker build -t $DOCKER_USER/midterm-app:$IMAGE_TAG .; then
        echo -e "${GREEN}✅ Build successful${NC}"
    else
        echo -e "${RED}❌ Build failed${NC}"
        exit 1
    fi
    
    echo ""
    echo "2️⃣  Testing image..."
    if docker run --rm $DOCKER_USER/midterm-app:$IMAGE_TAG node --version; then
        echo -e "${GREEN}✅ Image test successful${NC}"
    else
        echo -e "${RED}❌ Image test failed${NC}"
        exit 1
    fi
    
    cd ../../
    
    echo ""
    echo -e "${GREEN}✅ Local test complete${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Push to Docker Hub:"
    echo "   docker push $DOCKER_USER/midterm-app:$IMAGE_TAG"
    echo ""
    echo "2. Deploy on AWS:"
    echo "   ./deploy-full-stack.sh 3 --docker-user $DOCKER_USER"
    echo ""
}

# Execute phase
case $PHASE in
    all)
        run_phase_1
        run_phase_2
        run_phase_3
        ;;
    1)
        run_phase_1
        ;;
    2)
        run_phase_2
        ;;
    3)
        run_phase_3
        ;;
    local)
        run_local_test
        ;;
    *)
        echo -e "${RED}❌ Unknown phase: $PHASE${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Verification:"
echo "  AWS: curl https://523h0020.site"
echo "  Local: docker-compose ps"
echo ""

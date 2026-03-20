# Docker & Docker Compose Deployment Guide
# Phase 3: Containerization

## Table of Contents
1. [Overview](#overview)
2. [Docker Image](#docker-image)
3. [Docker Compose](#docker-compose)
4. [Deployment Steps](#deployment-steps)
5. [Nginx Integration](#nginx-integration)
6. [Management](#management)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### What's New?
- **Containerized Application**: Express.js app runs in Docker container
- **MongoDB Container**: Database also containerized for easier management
- **Service Networking**: Containers communicate via service names (mongodb:27017)
- **Persistent Volumes**: Data survives container restarts
- **Nginx Proxy**: Host's Nginx routes traffic to Docker container

### Architecture
```
Internet (TCP 80/443)
  ↓
Nginx (Host OS) - /etc/nginx/sites-available/midterm-app
  ↓
Docker Container (localhost:3000) - midterm-app
  ↓
MongoDB Container - mongodb (172.x.x.x:27017)
  ↓
Persistent Volume (/var/lib/midterm-app/mongodb)
```

---

## Docker Image

### Multi-Stage Build

**File**: `Dockerfile`

Features:
- **Stage 1 (Builder)**: Node:20-alpine + npm ci
  - Installs production dependencies only
  - Reduces final image size
  
- **Stage 2 (Runtime)**: Minimal alpine image
  - Copies only runtime files from builder
  - Adds non-root user (nodejs) for security
  - Includes dumb-init for proper signal handling
  - Health checks configured

**Build Command**:
```bash
docker build -t your-username/midterm-app:1.0.0 .
```

**Resulting Image Size**: ~200MB (vs 700MB+ with single-stage)

### Image Layers
```
Layer 1: node:20-alpine (base)                      ~150MB
Layer 2: npm dependencies (from builder)             ~50MB
Layer 3: App code + non-root user                    ~5MB
─────────────────────────────────────────────────
Total:                                              ~205MB
```

---

## Docker Compose

### Services Configuration

**File**: `docker-compose.yml`

#### Service 1: MongoDB
```yaml
mongodb:
  image: mongo:8.0-alpine
  restart: unless-stopped
  ports:
    - "27017:27017"
  volumes:
    - mongodb_data:/data/db
  healthcheck: [checks if MongoDB is responsive]
```

**Features**:
- Auto-restart on failure
- Port mapping for local development
- Named volume for persistent data
- Health check every 10 seconds

#### Service 2: Web (Node.js)
```yaml
web:
  image: your-username/midterm-app:latest
  restart: unless-stopped
  ports:
    - "3000:3000"
  environment:
    MONGO_URI: mongodb://mongodb:27017/products_db
  volumes:
    - ./public/uploads:/app/public/uploads
    - ./logs:/app/logs
  depends_on:
    mongodb: {condition: service_healthy}
```

**Features**:
- Connects to MongoDB via service name `mongodb`
- Environment variables configured
- User uploads persist on host
- Waits for MongoDB health check before starting

### Networking
```yaml
networks:
  midterm-network:
    driver: bridge
```
- All containers on same network
- Communicate via `servicename:port` (not IP)
- Example: `mongodb://mongodb:27017`

### Volumes
```yaml
volumes:
  mongodb_data:
    driver: local
    device: /var/lib/midterm-app/mongodb  # Host path
```
- Named volume `mongodb_data`
- Bound to host directory `/var/lib/midterm-app/mongodb`
- Persistent after container deletion

---

## Deployment Steps

### Step 1: Prepare Environment

#### Local Machine
```bash
# Clone/navigate to repository
cd ~/Projects/DevOPs/Midterm/DEVOPS

# Copy environment file
cp .env.docker.example .env.docker

# Edit .env.docker with your Docker Hub username
nano .env.docker
```

#### Edit .env.docker
```env
DOCKER_HUB_USERNAME=your-docker-hub-username
IMAGE_VERSION=1.0.0
```

### Step 2: Build Docker Image (Local)

```bash
# Option A: Manual build
cd sample-midterm-project/sample-midterm-node.js-project
docker build -t your-username/midterm-app:1.0.0 .

# Option B: Use script
bash scripts/docker-build-push.sh your-username 1.0.0
```

**Build Process**:
1. Copy package.json/package-lock.json
2. npm ci (clean install)
3. Copy application code
4. Create non-root user
5. Set ENTRYPOINT and CMD
6. Final image: ~205MB

**Verify Build**:
```bash
docker images | grep midterm-app
docker run --rm your-username/midterm-app:1.0.0 node --version
```

### Step 3: Push to Docker Hub

```bash
# Login
docker login -u your-username

# Push
docker push your-username/midterm-app:1.0.0
docker push your-username/midterm-app:latest

# Verify on Docker Hub
# https://hub.docker.com/r/your-username/midterm-app
```

### Step 4: Deploy on AWS

#### Connect to AWS Server
```bash
ssh -i "Midterm.pem" ubuntu@44.207.47.147
```

#### Copy docker-compose.yml
```bash
# Option A: From local machine
scp -i Midterm.pem docker-compose.yml ubuntu@44.207.47.147:/tmp/

# Option B: On AWS server, clone from git
git clone <repo> /var/www/midterm-app
cd /var/www/midterm-app
```

#### Deploy Containers
```bash
# Navigate to app directory
mkdir -p /var/www/midterm-app
cd /var/www/midterm-app

# Copy docker-compose.yml
cp /tmp/docker-compose.yml .

# Copy .env.docker
cp .env.docker.example .env.docker
nano .env.docker  # Edit if needed

# Deploy
bash scripts/docker-deploy.sh
```

**Deployment Steps** (in docker-deploy.sh):
1. Create volume directories: /var/lib/midterm-app/mongodb
2. Pull images from Docker Hub
3. Start containers with docker-compose up -d
4. Wait for services health checks (40 seconds)
5. Verify MongoDB and Web app connectivity

**Verify Deployment**:
```bash
# Check running containers
docker-compose ps

# Output should show:
# NAME            STATUS
# mongodb         Up ... (healthy)
# midterm-app     Up ... (healthy)

# Check logs
docker-compose logs

# Test application
curl http://localhost:3000
```

---

## Nginx Integration

### Why Separate Nginx from Docker?

| Aspect | Docker Container | Host Nginx |
|--------|-----------------|-----------|
| SSL Certificate | Needs mount, restart required | Centralized management |
| Updates | Container restart | Reload, no app downtime |
| Multiple Backends | N/A | Can reverse proxy multiple services |
| Let's Encrypt Renewal | Manual in container | Auto via cron |

### Nginx Configuration

**File**: `/etc/nginx/sites-available/midterm-app`

Generated by: `docker-nginx-proxy.sh`

#### HTTP to HTTPS Redirect
```nginx
server {
    listen 80;
    server_name 523h0020.site www.523h0020.site;
    
    # Redirect to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}
```

#### HTTPS Proxy Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name 523h0020.site www.523h0020.site;
    
    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/523h0020.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/523h0020.site/privkey.pem;
    
    # Proxy to Docker container
    location / {
        proxy_pass http://localhost:3000;  # Docker container
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Setup Steps

```bash
# 1. Configure Nginx for Docker
bash scripts/docker-nginx-proxy.sh

# 2. Test Nginx
sudo nginx -t

# 3. Restart Nginx
sudo systemctl restart nginx

# 4. Check status
sudo systemctl status nginx

# 5. Test locally
curl http://localhost:3000          # Internal
curl http://523h0020.site           # Via Nginx
curl https://523h0020.site          # HTTPS
```

### Certificate Installation

1. **Obtain Certificate** (if not done yet):
```bash
sudo certbot certonly --standalone -d 523h0020.site -d www.523h0020.site -m lenamgiang5@gmail.com
```

2. **Auto-renewal**:
```bash
sudo certbot renew --dry-run
systemctl status certbot.timer  # Auto-renewal enabled
```

---

## Management

### Docker Compose Commands

```bash
# Start all services
docker-compose up -d

# View running containers
docker-compose ps

# View logs
docker-compose logs -f              # All services
docker-compose logs -f web          # Just web app
docker-compose logs -f mongodb      # Just MongoDB

# Execute commands in containers
docker-compose exec web bash        # Shell in web container
docker-compose exec mongodb mongosh # MongoDB shell

# Stop services
docker-compose stop                 # Graceful stop
docker-compose down                 # Stop and remove containers

# Restart
docker-compose restart web          # Restart one service
docker-compose restart              # Restart all
```

### Management Script

**File**: `scripts/docker-manage.sh`

Usage:
```bash
# Start
./docker-manage.sh start

# View logs
./docker-manage.sh logs web
./docker-manage.sh logs all

# Backup MongoDB
./docker-manage.sh backup

# Restore MongoDB
./docker-manage.sh restore ./backups/mongodb_backup_20260320_120000.tar.gz

# Health check
./docker-manage.sh health

# Open MongoDB shell
./docker-manage.sh db-shell

# Execute command in web container
./docker-manage.sh shell npm test
```

### Persistent Uploads

User uploads are stored in `./public/uploads` which is mounted as volume:

```yaml
volumes:
  - ./public/uploads:/app/public/uploads
```

**Persistence Verification**:
```bash
# Upload file via web interface
# Then stop container
docker-compose stop web

# File still exists
ls -la public/uploads/

# Restart container
docker-compose up -d web

# File is still there!
```

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs web

# Common issues:
# 1. Port 3000 already in use
sudo lsof -i :3000
sudo kill -9 <PID>

# 2. MongoDB not healthy
docker-compose logs mongodb

# 3. Memory issues
docker stats
```

### MongoDB Connection Failed

```bash
# Check MongoDB container
docker-compose ps mongodb

# Check MongoDB logs
docker-compose logs mongodb

# Connect to MongoDB directly
docker-compose exec mongodb mongosh

# Test from web container
docker-compose exec web node -e "
  require('mongoose').connect('mongodb://mongodb:27017/products_db')
    .then(() => console.log('✅ Connected'))
    .catch(err => console.error('❌', err.message))
"
```

### Image Pull Failed

```bash
# Login to Docker Hub
docker login

# Try pulling manually
docker pull your-username/midterm-app:latest

# Check Docker Hub image page
# https://hub.docker.com/r/your-username/midterm-app
```

### Nginx Not Proxying

```bash
# Test Nginx config
sudo nginx -t

# Check Nginx is running
sudo systemctl status nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check if Docker container is listening on 3000
netstat -tlnp | grep 3000
docker-compose ps
```

### Data Loss on Container Removal

If you accidentally run `docker-compose down -v`:

```bash
# Volumes should still be at /var/lib/midterm-app/mongodb
ls -la /var/lib/midterm-app/mongodb/

# Restore container and reattach volume
docker-compose up -d

# Data should be restored!
```

---

## Security Considerations

1. **Non-root User**: Container runs as `nodejs:nodejs`, not root
2. **Health Checks**: Automatic service monitoring
3. **Restart Policy**: `unless-stopped` for auto-recovery
4. **Resource Limits**: CPU and memory capped in docker-compose
5. **Nginx SSL**: All traffic encrypted with Let's Encrypt
6. **Volume Permissions**: Uploads directory properly owned

---

## Performance Optimization

1. **Image Size**: 205MB (multi-stage build optimized)
2. **Layers**: 3-4 cached layers for faster rebuilds
3. **Health Checks**: 30-second interval, 40-second startup period
4. **Memory Limits**: Web: 512MB, MongoDB: auto

---

## Next Steps

1. ✅ Build Docker image locally
2. ✅ Push to Docker Hub
3. ✅ Deploy containers on AWS
4. ✅ Configure Nginx proxy
5. ⏳ Setup SSL certificate (if not done)
6. ⏳ Test full stack: https://523h0020.site

---

## Commands Reference

| Task | Command |
|------|---------|
| Build image | `docker build -t username/midterm-app:1.0.0 .` |
| Push to hub | `docker push username/midterm-app:1.0.0` |
| Deploy | `docker-compose up -d` |
| View logs | `docker-compose logs -f` |
| MongoDB shell | `docker-compose exec mongodb mongosh` |
| Backup data | `./docker-manage.sh backup` |
| Restore data | `./docker-manage.sh restore <file>` |
| Health check | `./docker-manage.sh health` |
| Stop all | `docker-compose stop` |
| Remove all | `docker-compose down` |

---

**Author**: DevOps Team  
**Created**: 2026-03-20  
**Docker Version**: 20.10+  
**Docker Compose Version**: 3.9+

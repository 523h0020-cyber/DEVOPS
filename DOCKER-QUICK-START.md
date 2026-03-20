# Docker Phase - Quick Start Guide

> **Phase 3 Containerization** - Complete Docker setup with Docker Compose

## 📋 Overview

Transform the midterm app from PM2-based to Docker-containerized deployment:

| Component | Before (PM2) | After (Docker) |
|-----------|--------|--------|
| **App Runtime** | Node.js on EC2 | Docker container |
| **Database** | MongoDB on EC2 | Docker container |
| **Process Mgmt** | PM2 daemon | Docker daemon + Compose |
| **Networking** | Direct ports | Service names (mongodb:27017) |
| **Persistence** | Direct disk | Named volumes |
| **Reverse Proxy** | Nginx → PM2 | Nginx → Docker:3000 |

---

## 🚀 Quick Start (3 Steps)

### Step 1: Build Image Locally (5 min)

```bash
# On local machine
cd ~/Projects/DevOPs/Midterm/DEVOPS/sample-midterm-project/sample-midterm-node.js-project

# Build multi-stage image
docker build -t your-username/midterm-app:1.0.0 .

# Test it
docker run -it --rm your-username/midterm-app:1.0.0 node --version
# Output: v20.x.x
```

### Step 2: Push to Docker Hub (2 min)

```bash
# Login to Docker Hub
docker login -u your-username

# Push image
docker push your-username/midterm-app:1.0.0
docker push your-username/midterm-app:latest

# Verify on Docker Hub
# https://hub.docker.com/r/your-username/midterm-app
```

### Step 3: Deploy on AWS (5 min)

```bash
# SSH to AWS
ssh -i Midterm.pem ubuntu@44.207.47.147

# Initialize Docker on server
bash /tmp/scripts/docker-init-aws.sh

# Deploy
cd /var/www/midterm-app
bash scripts/docker-deploy.sh

# Verify
bash scripts/docker-verify.sh
```

✅ **Done!** App now running in Docker containers.

---

## 📦 What's Included

### Files Created

1. **Dockerfile** - Multi-stage optimized build
   - ~200MB final image (vs 700MB+ single-stage)
   - Non-root user security
   - Health checks

2. **docker-compose.yml** - 2-service stack
   - Service 1: `web` (Node.js app on port 3000)
   - Service 2: `mongodb` (Database on port 27017)
   - Automatic networking via service names
   - Named volumes for persistence
   - Health checks + restart policies

3. **Scripts**
   - `docker-build-push.sh` - Build & push image
   - `docker-deploy.sh` - Deploy containers on AWS
   - `docker-nginx-proxy.sh` - Configure Nginx for Docker
   - `docker-manage.sh` - Management commands
   - `docker-verify.sh` - Verify deployment
   - `docker-troubleshoot.sh` - Debug issues
   - `docker-init-aws.sh` - AWS server setup

4. **Config Files**
   - `.dockerignore` - Exclude files from image
   - `.env.docker.example` - Environment variables
   - `.github/workflows/docker-build.yml` - CI/CD automation

5. **Documentation**
   - `DOCKER-DEPLOYMENT-GUIDE.md` - Complete reference

---

## 🔄 Deployment Workflow

### Local Machine (Build & Push)
```
┌─────────────────────────────────────────────┐
│ 1. Edit code                                │
│ 2. docker build -t user/app:1.0.0 .        │
│ 3. docker push user/app:1.0.0              │
│ 4. Image now on Docker Hub                 │
└─────────────────────────────────────────────┘
                    ↓
            docker pull user/app:1.0.0
                    ↓
┌─────────────────────────────────────────────┐
│ AWS Server (Deploy & Run)                  │
│ 1. docker-compose pull                     │
│ 2. docker-compose up -d                    │
│ 3. Containers running with persistent vol  │
│ 4. Nginx → Docker → App                    │
└─────────────────────────────────────────────┘
```

---

## 🌐 Networking

### Container Communication
```yaml
web container (172.x.x.x:3000)
    ↓ connects via hostname
mongodb container (172.x.x.x:27017)
    ↓ MONGO_URI = mongodb://mongodb:27017
```

Containers on same network can resolve `mongodb` → IP automatically.

**Key Point**: Service names work without manual IP configuration.

---

## 💾 Data Persistence

### MongoDB Volumes
```yaml
volumes:
  mongodb_data:
    device: /var/lib/midterm-app/mongodb  # Host path
```

**Persistence Test**:
```bash
# Stop container
docker-compose stop web

# Data still exists
ls -la public/uploads/

# Restart
docker-compose up -d web

# Data is still there!
```

---

## 🔐 Security Features

✅ **Non-root User**: Container runs as `nodejs:nodejs`
✅ **Health Checks**: Automatic service monitoring
✅ **Restart Policy**: Auto-recovery with `unless-stopped`
✅ **Resource Limits**: CPU and memory capped
✅ **Nginx SSL**: HTTPS with Let's Encrypt
✅ **Volume Permissions**: Proper ownership

---

## 📊 Image Optimization

### Multi-Stage Build Benefits

**Builder Stage**:
- Full Node.js 20
- Development dependencies
- npm ci

**Runtime Stage**:
- Minimal Alpine base
- Production dependencies only
- ~205MB final size

### Layer Caching
```
Layer 1: node:20-alpine base              150MB (cached)
Layer 2: npm dependencies (rarely changes) 50MB (cached)
Layer 3: App code (changes often)          5MB (not cached)
─────────────────────────────────
Total:                                     205MB
```

---

## 🔧 Management Commands

```bash
# Quick reference
./docker-manage.sh start           # Start
./docker-manage.sh logs web        # View logs
./docker-manage.sh health          # Health check
./docker-manage.sh backup          # MongoDB backup
./docker-manage.sh db-shell        # MongoDB shell
./docker-manage.sh shell npm test  # Run command in web
./docker-manage.sh restart         # Restart all
./docker-manage.sh stop            # Stop gracefully
```

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Containers running: `docker-compose ps`
- [ ] MongoDB healthy: `docker-compose logs mongodb`
- [ ] Web app responding: `curl http://localhost:3000`
- [ ] Database connected: `curl http://localhost:3000 | grep -i product`
- [ ] Uploads persisting: Files survive `docker stop/start`
- [ ] Nginx proxying: `curl https://523h0020.site`
- [ ] Health checks passing: `docker-compose ps` shows `(healthy)`

---

## 🐛 Common Issues

### Container won't start
```bash
docker-compose logs web
# Check for Port 3000 already in use
sudo lsof -i :3000
```

### MongoDB connection failed
```bash
docker-compose exec mongodb mongosh
# Test from web container:
docker-compose exec web node -e "
  require('mongoose').connect('mongodb://mongodb:27017/products_db')
    .then(() => console.log('Connected'))
    .catch(err => console.error(err))
"
```

### Image pull failed
```bash
docker login -u your-username
docker pull your-username/midterm-app:latest
```

### Nginx not proxying
```bash
sudo nginx -t
sudo systemctl restart nginx
sudo tail -f /var/log/nginx/error.log
```

### Data lost after `docker-compose down`
Data should be in `/var/lib/midterm-app/mongodb` even after removal.

---

## 📚 Full Documentation

See **DOCKER-DEPLOYMENT-GUIDE.md** for:
- Complete architecture diagrams
- Detailed step-by-step instructions
- Troubleshooting procedures
- Performance optimization tips
- Security best practices

---

## 🎯 Next Steps

1. **Build image locally** (5 min):
   ```bash
   bash scripts/docker-build-push.sh your-username 1.0.0
   ```

2. **Push to Docker Hub** (2 min):
   ```bash
   docker push your-username/midterm-app:1.0.0
   ```

3. **Deploy on AWS** (5 min):
   ```bash
   ssh ubuntu@44.207.47.147
   bash scripts/docker-init-aws.sh
   cd /var/www/midterm-app && bash scripts/docker-deploy.sh
   ```

4. **Configure Nginx** (2 min):
   ```bash
   bash scripts/docker-nginx-proxy.sh
   ```

5. **Verify** (2 min):
   ```bash
   bash scripts/docker-verify.sh
   ```

**Total time: ~15 minutes** ✅

---

## 🔄 CI/CD Integration (Optional)

GitHub Actions automatically builds and pushes on every push to `main`:

**.github/workflows/docker-build.yml** configured for:
- Multi-stage caching
- Docker Hub push
- Auto-deploy to AWS (with SSH keys)

**Setup**:
1. Add GitHub Secrets:
   - `DOCKER_HUB_USERNAME`
   - `DOCKER_HUB_TOKEN`
   - `SSH_PRIVATE_KEY`
   - `AWS_EC2_HOST`

2. Push to main → Auto-build, push, deploy ✅

---

## 📞 Support

| Issue | Solution |
|-------|----------|
| Docker not installed? | `bash docker-init-aws.sh` |
| Image build fails? | See DOCKER-DEPLOYMENT-GUIDE.md § Troubleshooting |
| Containers not communicating? | Run `docker-troubleshoot.sh connections` |
| Need MongoDB backup? | `./docker-manage.sh backup` |
| Want to debug live app? | `./docker-manage.sh shell bash` |

---

**Created**: 2026-03-20  
**Container Registry**: Docker Hub  
**Orchestration**: Docker Compose v3.9+  
**Status**: ✅ Production Ready

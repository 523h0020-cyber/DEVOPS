
# 🚀 MIDTERM APP - DEPLOYMENT SCRIPTS

## 📋 Overview

Complete deployment automation for:
- Phase 1: Infrastructure (Node.js, PM2, Nginx)
- Phase 2: Database (MongoDB)  
- Phase 3: Containerization (Docker, Docker Compose)

---

## 🚀 Quick Start

### Option A: Full Stack (All Phases)

```bash
# Local: Build Docker image
bash deploy-full-stack.sh local --docker-user your-username

# AWS: Deploy all phases (1, 2, 3)
ssh ubuntu@44.207.47.147
bash deploy-full-stack.sh all --docker-user your-username
```

### Option B: Docker Only (Phase 3)

```bash
# AWS Server
bash deploy-full-stack.sh 3 --docker-user your-username
```

---

## 📁 Scripts Breakdown

### Build & Deploy (Top Level)

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy-full-stack.sh` | Orchestrate all phases | `./deploy-full-stack.sh all` |
| `deploy-to-aws.sh` | Phase 1-2 (PM2 based) | `sudo bash deploy-to-aws.sh` |

### Phase Scripts

| Phase | Script | Purpose |
|-------|--------|---------|
| 1 | `setup.sh` | Install Node.js, PM2, Nginx |
| 2 | `phase2.sh` | MongoDB, app deployment |
| 3 | `phase3-ssl-setup.sh` | SSL with Certbot |

### Docker Phase 3 Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `docker-build-push.sh` | Build & push image | `bash docker-build-push.sh your-username 1.0.0` |
| `docker-deploy.sh` | Deploy containers | `bash docker-deploy.sh` |
| `docker-nginx-proxy.sh` | Configure Nginx proxy | `bash docker-nginx-proxy.sh` |
| `docker-manage.sh` | Manage containers | `./docker-manage.sh start` |
| `docker-verify.sh` | Verify deployment | `bash docker-verify.sh` |
| `docker-troubleshoot.sh` | Debug issues | `bash docker-troubleshoot.sh logs` |
| `docker-init-aws.sh` | Setup Docker on AWS | `bash docker-init-aws.sh` |

### Database Management

| Script | Purpose | Usage |
|--------|---------|-------|
| `backup-mongodb.sh` | Backup database | `bash backup-mongodb.sh` |
| `restore-mongodb.sh` | Restore from backup | `bash restore-mongodb.sh /path/file.tar.gz` |

### Monitoring & Troubleshooting

| Script | Purpose | Usage |
|--------|---------|-------|
| `health-check.sh` | System health | `bash health-check.sh` |
| `troubleshoot-pm2.sh` | PM2 issues | `bash troubleshoot-pm2.sh` |
| `diagnose-port-3000.sh` | Port debugging | `bash diagnose-port-3000.sh` |
| `fix-port-3000.sh` | Port recovery | `sudo bash fix-port-3000.sh` |

---

## 🐳 Docker Deployment Steps

### Step 1: Build Image (Local)

```bash
cd ~/Projects/DevOPs/Midterm/DEVOPS

# Build Docker image
bash scripts/docker-build-push.sh your-username 1.0.0

# Test image
docker run --rm your-username/midterm-app:1.0.0 node --version
```

### Step 2: Push to Docker Hub

```bash
docker login -u your-username
docker push your-username/midterm-app:1.0.0
```

### Step 3: Deploy on AWS

```bash
ssh -i Midterm.pem ubuntu@44.207.47.147

# Initialize Docker environment
bash scripts/docker-init-aws.sh

# Deploy containers
cd /var/www/midterm-app
bash scripts/docker-deploy.sh

# Configure Nginx
bash scripts/docker-nginx-proxy.sh

# Verify
bash scripts/docker-verify.sh
```

---

## 📊 Docker Management Commands

### Quick Management
```bash
./docker-manage.sh start              # Start all
./docker-manage.sh logs web           # View web logs
./docker-manage.sh logs mongodb       # View database logs
./docker-manage.sh health             # Health check
./docker-manage.sh db-shell           # MongoDB shell
./docker-manage.sh backup             # Backup database
./docker-manage.sh restore FILE       # Restore database
./docker-manage.sh restart            # Restart all
./docker-manage.sh stop               # Stop gracefully
```

### Docker Compose Native
```bash
docker-compose ps                     # Show status
docker-compose logs -f                # View logs
docker-compose restart                # Restart
docker-compose stop                   # Stop
docker-compose down                   # Remove
```

---

## 🔧 Troubleshooting

### Diagnose Issues
```bash
./docker-troubleshoot.sh logs                # Show detailed logs
./docker-troubleshoot.sh connections        # Test networking
./docker-troubleshoot.sh volumes            # Check volumes
./docker-troubleshoot.sh ports              # Verify bindings
./docker-troubleshoot.sh resources          # Resource usage
```

### Check Port 3000 (Legacy PM2)
```bash
sudo lsof -i :3000
sudo bash scripts/fix-port-3000.sh
```

### MongoDB Issues (Docker)
```bash
docker-compose exec mongodb mongosh
db.adminCommand('ping')
use products_db
db.products.countDocuments()
```

---

## ✅ Deployment Checklist

- [ ] Docker Hub account created
- [ ] Image built locally: `docker images | grep midterm`
- [ ] Image pushed: Check Docker Hub
- [ ] AWS server initialized: `bash docker-init-aws.sh`
- [ ] Containers running: `docker-compose ps`
- [ ] MongoDB healthy: `docker-compose logs mongodb`
- [ ] Web app responding: `curl http://localhost:3000`
- [ ] Nginx proxying: `curl https://523h0020.site`
- [ ] Data persisting: Files in `public/uploads/`
- [ ] Health checks passing: `grep healthy docker-compose ps`

---

## 🌐 Configuration

### Environment Variables (.env.docker)
```env
DOCKER_HUB_USERNAME=your-username
IMAGE_VERSION=1.0.0
NODE_ENV=production
PORT=3000
MONGO_URI=mongodb://mongodb:27017/products_db
DOMAIN=523h0020.site
EMAIL=lenamgiang5@gmail.com
```

### Nginx Configuration
Auto-configured by `docker-nginx-proxy.sh`:
- Port 80 → HTTPS redirect
- Port 443 → Docker container proxy (localhost:3000)
- Path: `/etc/nginx/sites-available/midterm-app`

---

## 📚 Documentation

- **DOCKER-QUICK-START.md** - Quick reference guide
- **DOCKER-DEPLOYMENT-GUIDE.md** - Complete documentation
- **AWS-DEPLOYMENT-GUIDE.md** - AWS EC2 setup guide

---

## 🔄 Updates & Maintenance

### Update App Code
```bash
# Local: Build new image
bash scripts/docker-build-push.sh your-username 1.1.0

# AWS: Pull and restart
docker-compose pull
docker-compose up -d
```

### Database Backup (Automated)
Runs daily at 2 AM. Manual backup:
```bash
./docker-manage.sh backup
```

### MongoDB Recovery
```bash
./docker-manage.sh restore backups/mongodb_backup_YYYYMMDD_HHMMSS.tar.gz
```

---

## 🔐 Security Notes

✅ Containers run as non-root user  
✅ Health checks every 30 seconds  
✅ Auto-restart on failure  
✅ Data persists across container restarts  
✅ HTTPS via Let's Encrypt  
✅ Resource limits enforced  

---

**Version**: 3.0 (Docker)  
**Updated**: 2026-03-20  
**Status**: ✅ Production Ready
 "Health check:          sudo bash health-check.sh"
 ""
 "YÊU CẦU"
 "================================"
 "✅ Port 3000: Node.js app"
 "✅ Port 80/443: Nginx reverse proxy"
 "✅ MongoDB: Lưu trữ dữ liệu (không mất khi tắt app)"
 "✅ SSL: HTTPS với Let's Encrypt"
 "✅ Backup: Hàng ngày lúc 2 AM"
 "✅ PM2: Tự động restart app nếu crash"
 ""

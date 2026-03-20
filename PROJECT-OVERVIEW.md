# 📊 MIDTERM PROJECT - COMPREHENSIVE OVERVIEW

**Last Updated:** March 20, 2026

---

## 🎯 PROJECT INFORMATION

| Item | Value |
|------|-------|
| **Repository** | 523h0020-cyber/DEVOPS |
| **Current Branch** | feature/setup-scripts (78f1f5a) |
| **Main Branch** | 66c3be1 (synced) |
| **Domain** | 523h0020.site |
| **Email** | lenamgiang5@gmail.com |
| **Port** | 3000 (Node.js) → 80/443 (Nginx) |
| **Database** | MongoDB 8.0 |
| **OS** | Ubuntu 24.04 LTS |

---

## 📁 PROJECT STRUCTURE

```
DEVOPS/
├── 📄 AWS-DEPLOYMENT-GUIDE.md          ← Complete deployment documentation
├── 📄 README.md                        ← Project overview
├── 📂 docs/                            ← General documentation
├── 📂 phase1/                          ← Phase 1 guide (Setup)
├── 📂 phase2/                          ← Phase 2 guide (App + MongoDB)
├── 📂 phase3/                          ← Phase 3 guide (SSL/HTTPS)
├── 📂 src/
│   └── sample-midterm-project/
│       └── sample-midterm-node.js-project/
│           ├── main.js                 ← Entry point
│           ├── package.json            ← Dependencies
│           ├── .env                    ← Environment config
│           ├── controllers/            ← Route handlers
│           ├── models/                 ← MongoDB models
│           ├── routes/                 ← API routes
│           ├── services/               ← Business logic
│           ├── views/                  ← EJS templates
│           ├── validators/             ← Input validation
│           └── public/
│               ├── css/                ← Stylesheets
│               ├── js/                 ← Frontend JS
│               ├── uploads/            ← User uploads
│               └── images/
└── 📂 scripts/
    ├── setup.sh                        ← Phase 1: Server setup
    ├── phase2.sh                       ← Phase 2: App + MongoDB
    ├── phase3-ssl-setup.sh             ← Phase 3: SSL/HTTPS
    ├── deploy-to-aws.sh                ← Master orchestration
    ├── ecosystem.config.js             ← PM2 configuration
    ├── backup-mongodb.sh               ← Daily backups
    ├── restore-mongodb.sh              ← Database recovery
    ├── health-check.sh                 ← System monitoring
    ├── troubleshoot-pm2.sh             ← PM2 troubleshooting
    ├── .env.example                    ← Environment template
    └── README.md                       ← Scripts guide
```

---

## 🚀 DEPLOYMENT SCRIPTS

### Available Scripts:

| Script | Purpose | Trigger |
|--------|---------|---------|
| **setup.sh** | Install Node.js, PM2, Nginx | Phase 1 |
| **phase2.sh** | Deploy MongoDB, App | Phase 2 |
| **phase3-ssl-setup.sh** | Configure HTTPS/SSL | Phase 3 |
| **deploy-to-aws.sh** | Orchestrate all phases | Full setup |
| **ecosystem.config.js** | PM2 cluster config | App startup |
| **backup-mongodb.sh** | MongoDB backup | Daily 2 AM |
| **restore-mongodb.sh** | Restore from backup | On demand |
| **health-check.sh** | Monitor system | On demand |
| **troubleshoot-pm2.sh** | Fix PM2 errors | On demand |

### Quick Deploy Command:
```bash
cd DEVOPS/scripts
sudo bash deploy-to-aws.sh
```

---

## 📦 APPLICATION STACK

### Backend (Node.js)
```json
{
  "name": "api",
  "version": "1.0.0",
  "main": "main.js",
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.0.0",
    "ejs": "^3.1.9",
    "dotenv": "^16.0.0",
    "express-validator": "^6.14.3",
    "multer": "^1.4.5-lts.1",
    "uuid": "^9.0.0"
  }
}
```

### Frontend
- **Template Engine:** EJS
- **Styling:** CSS
- **JavaScript:** Vanilla JS (public/js/ui.js)

### Database
- **Type:** MongoDB 8.0
- **Host:** localhost:27017
- **Database:** products_db
- **Collections:** products

### Infrastructure
- **Process Manager:** PM2
- **Reverse Proxy:** Nginx
- **SSL/HTTPS:** Let's Encrypt
- **Backup:** Daily (7-day retention)

---

## 🔄 DATA PERSISTENCE

### MongoDB Storage
- **Path:** `/var/lib/mongodb`
- **Persistent:** Yes (SSD volume)
- **Auto-recovery:** On server restart

### PM2 Auto-restart
- **Memory limit:** 500MB (auto-restart if exceeded)
- **Auto-recovery:** On crash
- **Cluster mode:** Max CPU cores

### Daily Backups
- **Schedule:** 2 AM (cron job)
- **Location:** `/var/backups/mongodb/`
- **Retention:** 7 days
- **Format:** Compressed tar.gz

### Restore Capability
```bash
sudo bash restore-mongodb.sh /var/backups/mongodb/backup_YYYYMMDD_HHMMSS.tar.gz
```

---

## 🛠️ KEY FEATURES

✅ **Completed:**
- ✔️ Complete Node.js + MongoDB application
- ✔️ Express API with routes, controllers, models
- ✔️ EJS templating with responsive UI
- ✔️ File upload capability
- ✔️ Input validation
- ✔️ All deployment scripts
- ✔️ PM2 process management
- ✔️ Nginx reverse proxy
- ✔️ MongoDB backup automation
- ✔️ SSL/HTTPS configuration
- ✔️ Health check monitoring
- ✔️ Troubleshooting scripts

🎯 **Ready for Production:**
- Domain: 523h0020.site ✅
- Email: lenamgiang5@gmail.com ✅
- Port: 3000 ✅
- Database: MongoDB ✅
- Data persistence: Enabled ✅
- Auto-backups: Daily ✅
- SSL: Let's Encrypt ✅

---

## 📋 GIT INFORMATION

### Branches:
```
* feature/setup-scripts (78f1f5a)  ← Current (3 commits ahead of remote)
  main (66c3be1)                   ← Sync with origin/main
```

### Recent Commits:
```
78f1f5a change                     ← Latest (3/20/2026)
6ce55e1 quick fix
5613b89 FIX FINAL
66c3be1 Merge feature/setup-scripts into main
aa7f6cf feat: add AWS deployment automation
```

### Current Status:
- ⚠️ **1 uncommitted change:** `scripts/setup.sh` (modified)
- ✅ **Branches synced**
- ✅ **Ready to push**

---

## 🚀 NEXT STEPS

### Option 1: Deploy to AWS Immediately
```bash
cd DEVOPS/scripts
sudo bash deploy-to-aws.sh
```

### Option 2: Deploy Step by Step
```bash
sudo bash setup.sh              # Phase 1
sudo bash phase2.sh             # Phase 2
sudo bash phase3-ssl-setup.sh   # Phase 3
```

### Option 3: Troubleshoot Existing Deployment
```bash
sudo bash health-check.sh           # Check system
sudo bash troubleshoot-pm2.sh       # Fix PM2 errors
pm2 logs midterm-app                # View app logs
```

---

## 📞 USEFUL COMMANDS

### Application Management
```bash
pm2 status                           # View all processes
pm2 logs midterm-app                 # View app logs
pm2 restart midterm-app              # Restart app
pm2 stop midterm-app                 # Stop app
pm2 delete midterm-app               # Delete from PM2
```

### Database Management
```bash
sudo systemctl status mongod         # Check MongoDB
sudo systemctl restart mongod        # Restart MongoDB
mongo                                # Connect to MongoDB
db.products.find()                   # Query products
```

### Nginx Management
```bash
sudo systemctl status nginx          # Check Nginx
sudo systemctl restart nginx         # Restart Nginx
sudo nginx -t                        # Test config
sudo tail -f /var/log/nginx/error.log   # View errors
```

### Monitoring
```bash
sudo bash health-check.sh            # Full health check
netstat -tlnp | grep 3000            # Check port 3000
df -h                                # Check disk space
free -h                              # Check memory
```

### Backup & Restore
```bash
sudo bash backup-mongodb.sh          # Manual backup
ls -lh /var/backups/mongodb/         # View backups
sudo bash restore-mongodb.sh /path/to/backup   # Restore
```

---

## ✅ DEPLOYMENT CHECKLIST

- [ ] SSH key ready
- [ ] AWS EC2 instance running (Ubuntu 24.04 LTS)
- [ ] Security group allows ports 22, 80, 443
- [ ] Domain DNS points to EC2 public IP
- [ ] Run `sudo bash deploy-to-aws.sh`
- [ ] Verify app: `https://523h0020.site`
- [ ] Check MongoDB: `db.products.countDocuments()`
- [ ] Check backups: `ls -lh /var/backups/mongodb/`
- [ ] Monitor logs: `pm2 logs midterm-app`
- [ ] Setup complete! 🎉

---

## 📚 DOCUMENTATION

| File | Content |
|------|---------|
| **AWS-DEPLOYMENT-GUIDE.md** | Complete deployment guide (Vietnamese) |
| **README.md** (root) | Project overview |
| **scripts/README.md** | Scripts usage guide |
| **src/.../README.md** | Application documentation |
| **phase{1,2,3}/README.md** | Phase-specific guides |
| **docs/README.md** | General documentation |

---

## 🔒 SECURITY STATUS

✅ **Configured:**
- HTTPS/SSL with Let's Encrypt
- Firewall rules (UFW)
- PM2 process isolation
- MongoDB restricted to localhost
- SSH key authentication

⚠️ **Recommendations:**
- Enable CloudWatch monitoring
- Setup AWS Backup vault
- Enable VPC security groups
- Configure RDS backup (if using RDS)
- Add WAF rules (if using CloudFront)

---

## 📊 RESOURCE SUMMARY

### Deployment Artifacts
- ✅ 8 shell scripts
- ✅ 1 PM2 ecosystem config
- ✅ 1 environment template
- ✅ Complete documentation (4+ guides)

### Application Code
- ✅ Main entry point (main.js)
- ✅ 5 route files
- ✅ 1 MongoDB model
- ✅ 1 controller file
- ✅ 1 service layer
- ✅ 1 validator file
- ✅ 4 EJS views

### Data Management
- ✅ Daily automated backups
- ✅ 7-day retention policy
- ✅ Restore capability
- ✅ No data loss on restart

### Monitoring
- ✅ Health check script
- ✅ PM2 logs
- ✅ Nginx logs
- ✅ MongoDB status
- ✅ Disk usage monitoring

---

**Status:** ✅ READY FOR PRODUCTION DEPLOYMENT

Last updated: March 20, 2026

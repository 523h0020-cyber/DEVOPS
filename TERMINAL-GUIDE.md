# 🖥️ TERMINAL GUIDE: Chạy Lệnh Ở Đâu?

> Hướng dẫn rõ ràng: Lệnh nào chạy ở Local, lệnh nào chạy ở AWS

---

## 📍 CÓ 2 TERMINALS

### Terminal 1️⃣: LOCAL MACHINE (Windows/Mac/Linux)
```
💻 Your Computer (Windows)
   ↓
PowerShell / CMD / Git Bash
   ↓
~/Projects/DevOPs/Midterm/DEVOPS
```

**Prompt sẽ như:**
```
PS C:\Users\YourName\Projects\DevOPs\Midterm\DEVOPS>
```

**Dùng cho:**
- Build Docker image
- Push to Docker Hub
- SSH to AWS
- Git commands

---

### Terminal 2️⃣: AWS SERVER
```
🌐 AWS EC2 Instance (Ubuntu 24.04)
   ↓
SSH Connection from Local
   ↓
ubuntu@ip-172-31-xx-xx:~
```

**Prompt sẽ như:**
```
ubuntu@ip-172-31-12-34:~$
```

**Dùng cho:**
- Deploy containers
- Manage Docker
- Check logs
- Test application

---

## 🎯 PHASE 3 COMMANDS: TERMINAL NÀO?

### ✅ LOCAL TERMINAL (Máy tính của bạn)

```bash
# Step 1: Navigate
cd ~/Projects/DevOPs/Midterm/DEVOPS
cd sample-midterm-project/sample-midterm-node.js-project

# 🖥️ TERMINAL: LOCAL
# PROMPT: PS C:\Users\YourName\...>
```

```bash
# Step 2: Build image
docker build -t your-username/midterm-app:1.0.0 .

# 🖥️ TERMINAL: LOCAL
# OUTPUT: [+] Building ... 205MB
# 📸 SCREENSHOT HERE
```

```bash
# Step 3: Verify image
docker images | grep midterm-app

# 🖥️ TERMINAL: LOCAL
# OUTPUT: your-username/midterm-app  1.0.0  ...  205MB
# 📸 SCREENSHOT HERE
```

```bash
# Step 4: Test image
docker run --rm your-username/midterm-app:1.0.0 node --version

# 🖥️ TERMINAL: LOCAL
# OUTPUT: v20.11.x
# 📸 SCREENSHOT HERE
```

```bash
# Step 5: Login to Docker Hub
docker login -u your-username

# 🖥️ TERMINAL: LOCAL
# PROMPT: Password: [nhập password]
# OUTPUT: Login Succeeded
# 📸 SCREENSHOT HERE
```

```bash
# Step 6: Push to Docker Hub
docker push your-username/midterm-app:1.0.0
docker push your-username/midterm-app:latest

# 🖥️ TERMINAL: LOCAL
# OUTPUT: Pushed ... digest: sha256:...
# 📸 SCREENSHOT HERE
```

---

### 🌐 AWS TERMINAL (SSH Connection)

```bash
# Step 7: SSH to AWS
ssh -i Midterm.pem ubuntu@44.207.47.147

# 🖥️ TERMINAL: LOCAL (nhập từ đây)
# ENTER AWS (Prompt thay đổi)
# 📸 SCREENSHOT: ubuntu@ip-172-31-xx-xx:~$
```

```bash
# Step 8: Navigate to app directory
cd /var/www/midterm-app
ls -la

# 🖥️ TERMINAL: AWS
# PROMPT: ubuntu@ip-172-31-xx-xx:/var/www/midterm-app$
# 📸 SCREENSHOT HERE
```

```bash
# Step 9: Initialize Docker (FIRST TIME ONLY)
bash scripts/docker-init-aws.sh

# 🖥️ TERMINAL: AWS
# OUTPUT: ✅ INITIALIZATION COMPLETE!
# 📸 SCREENSHOT HERE
```

```bash
# Step 10: Deploy containers
bash scripts/docker-deploy.sh

# 🖥️ TERMINAL: AWS
# OUTPUT: ✅ DEPLOYMENT COMPLETE!
# OUTPUT: NAME  IMAGE  STATUS ... (healthy)
# 📸 SCREENSHOT HERE
```

```bash
# Step 11: Check containers
docker-compose ps

# 🖥️ TERMINAL: AWS
# PROMPT: ubuntu@ip-172-31-xx-xx:/var/www/midterm-app$
# OUTPUT: mongodb ... (healthy)
#         midterm-app ... (healthy)
# 📸 SCREENSHOT HERE
```

```bash
# Step 12: Test web app
curl http://localhost:3000 | head -20

# 🖥️ TERMINAL: AWS
# OUTPUT: <!DOCTYPE html>
#         ...
#         <title>Midterm App</title>
#         ...
# 📸 SCREENSHOT HERE
```

```bash
# Step 13: Test MongoDB
docker-compose exec mongodb mongosh

# 🖥️ TERMINAL: AWS - NOW IN MONGODB SHELL
# PROMPT: products_db>
# ⏬ Type next command
```

```javascript
// Still in MongoDB shell
use products_db
db.products.countDocuments()

// 🖥️ STILL AWS TERMINAL (inside MongoDB)
// OUTPUT: 11
// 📸 SCREENSHOT HERE
```

```bash
# Step 14: Exit MongoDB
exit

# 🖥️ TERMINAL: AWS (back to bash)
# PROMPT: ubuntu@ip-172-31-xx-xx:/var/www/midterm-app$
```

```bash
# Step 15: Configure Nginx
bash scripts/docker-nginx-proxy.sh

# 🖥️ TERMINAL: AWS
# OUTPUT: ✅ NGINX CONFIGURATION COMPLETE!
# 📸 SCREENSHOT HERE
```

```bash
# Step 16: Verify all
bash scripts/docker-verify.sh

# 🖥️ TERMINAL: AWS
# OUTPUT: ✅ VERIFICATION COMPLETE!
# 📸 SCREENSHOT HERE
```

```bash
# Step 17: Health check
./docker-manage.sh health

# 🖥️ TERMINAL: AWS
# OUTPUT: ✅ MongoDB: HEALTHY
#         ✅ Web App: HEALTHY
# 📸 SCREENSHOT HERE
```

```bash
# Step 18: Test domain (HTTPS)
curl -k https://523h0020.site | head -20

# 🖥️ TERMINAL: AWS
# OUTPUT: <!DOCTYPE html>
#         ...
# 📸 SCREENSHOT HERE
```

```bash
# Step 19: Exit AWS (optional)
exit

# 🖥️ TERMINAL: AWS → LOCAL
# PROMPT: Back to PS C:\Users\...>
```

---

## 📊 QUICK REFERENCE TABLE

| Step | Command | Terminal | Prompt |
|------|---------|----------|--------|
| 1-6 | docker build / push | LOCAL | `PS C:\...>` |
| 7 | ssh | LOCAL | `PS C:\...>` |
| 8-19 | Deploy / Verify | AWS | `ubuntu@ip-172-31-xx-xx:~$` |

---

## 🎯 CỤ THỂ: CHO TỪ BƯỚC NÀO TỚI BƯỚC NÀO

### 📦 LOCAL BUILD PHASE (Steps 1-6)

**Chạy ở đâu:** 🖥️ **LOCAL MACHINE**

```
PowerShell / CMD / Terminal trên máy của bạn
↓
Cùng thư mục: C:\Users\YourName\Projects\DevOPs\Midterm\DEVOPS
↓
Prompt: PS C:\Users\YourName\Projects\DevOPs\Midterm\DEVOPS>
```

**Các lệnh:**
```bash
cd sample-midterm-project/sample-midterm-node.js-project
docker build -t username/midterm-app:1.0.0 .      # 📸
docker images | grep midterm-app                  # 📸
docker run --rm username/midterm-app:1.0.0 node --version  # 📸
docker login -u username                          # 📸
docker push username/midterm-app:1.0.0            # 📸
```

**Kết thúc**: Khi thấy push complete, bạn hoàn thành LOCAL PHASE

---

### 🚀 AWS DEPLOYMENT PHASE (Steps 7-19)

**Chạy ở đâu:** 🌐 **AWS SERVER via SSH**

**Lệnh SSH:**
```bash
ssh -i Midterm.pem ubuntu@44.207.47.147
```

**Sau SSH, prompt thay đổi:**
```
TRƯỚC: PS C:\Users\YourName\...
SAU:   ubuntu@ip-172-31-xx-xx:~$
```

**Các lệnh ở AWS:**
```bash
cd /var/www/midterm-app
bash scripts/docker-init-aws.sh                   # 📸
bash scripts/docker-deploy.sh                     # 📸
docker-compose ps                                 # 📸
curl http://localhost:3000 | head -20             # 📸
docker-compose exec mongodb mongosh              # 🌐
  (inside MongoDB: db.products.countDocuments())  # 📸
docker-compose exec web bash                      # 🌐
bash scripts/docker-verify.sh                     # 📸
./docker-manage.sh health                         # 📸
curl -k https://523h0020.site | head -20          # 📸
```

---

## 🚨 CÁCH NHẬN BIẾT TERMINAL

### 📍 Local Prompt Examples:

**PowerShell (Windows):**
```
PS C:\Users\YourName\Projects\DevOPs\Midterm\DEVOPS>
```

**Git Bash (Windows):**
```
YourName@DESKTOP-ABC ~/Projects/DevOPs/Midterm/DEVOPS (feature/setup-scripts)
$
```

**Terminal (Mac/Linux):**
```
yourname@MacBook-Pro ~/Projects/DevOPs/Midterm/DEVOPS %
```

### 🌐 AWS Prompt Examples:

**SSH Connected:**
```
ubuntu@ip-172-31-12-34:~$
ubuntu@ip-172-31-12-34:/var/www/midterm-app$
```

**MongoDB Shell (inside AWS):**
```
products_db>
```

---

## 🎓 FLOW DIAGRAM

```
START
  ↓
LOCAL TERMINAL #1 (PowerShell)
  │
  ├─ docker build ..................... 📸 Screenshot 1
  ├─ docker push ....................... 📸 Screenshot 2-3
  └─ ssh -i Midterm.pem ubuntu@... 🌐 SWITCH TO AWS
        ↓
AWS TERMINAL (SSH Connected)
  │
  ├─ bash scripts/docker-init-aws.sh .. 📸 Screenshot 4
  ├─ bash scripts/docker-deploy.sh .... 📸 Screenshot 5
  ├─ docker-compose ps ................ 📸 Screenshot 6
  ├─ curl http://localhost:3000 ...... 📸 Screenshot 7
  ├─ docker-compose exec mongodb mongosh
  │   └─ db.products.countDocuments() . 📸 Screenshot 8
  ├─ bash scripts/docker-verify.sh .... 📸 Screenshot 9
  ├─ ./docker-manage.sh health ........ 📸 Screenshot 10
  ├─ curl -k https://523h0020.site ... 📸 Screenshot 11
  └─ exit
        ↓
LOCAL TERMINAL #1 (Back)
  └─ DONE ✓
```

---

## ⚠️ THƯỜNG GẶP: NHẦM TERMINAL

### ❌ Sai: Chạy AWS commands ở Local

```
PS C:\Users\...> docker-compose exec mongodb mongosh
❌ ERROR: docker-compose.yml not found
```

**Vì:** Local máy bạn không có `docker-compose.yml` (tệp ở AWS)

**Fix:** SSH vào AWS trước
```
PS C:\Users\...> ssh -i Midterm.pem ubuntu@44.207.47.147
ubuntu@ip-172-31-xx-xx:~$ docker-compose exec ...
✓ OK
```

### ❌ Sai: Chạy Local build trên AWS

```
ubuntu@ip-172-31-xx-xx:~$ docker build -t user/midterm-app:1.0.0 .
❌ ERROR: Dockerfile not found
```

**Vì:** Dockerfile ở `/var/www/midterm-app`, không ở app directory

**Fix:** SSH vào AWS, navigate đúng
```
ubuntu@ip-172-31-xx-xx:~$ cd /var/www/midterm-app
ubuntu@ip-172-31-xx-xx:/var/www/midterm-app$ bash scripts/docker-deploy.sh
✓ OK (deploy, không build)
```

---

## 📋 CHECKLIST: TERMINAL SETTINGS

### ✅ Setup Local Terminal

- [ ] Open PowerShell / Git Bash
- [ ] Navigate: `cd ~/Projects/DevOPs/Midterm/DEVOPS`
- [ ] Check prompt shows correct folder
- [ ] Docker installed: `docker --version`
- [ ] SSH key ready: `Midterm.pem` in home folder

### ✅ Setup AWS Access

- [ ] SSK key path: `~/Midterm.pem` (or full path)
- [ ] Key permissions: 600 (`chmod 600 Midterm.pem`)
- [ ] Can SSH: `ssh -i Midterm.pem ubuntu@44.207.47.147`
- [ ] Once in, can see: `ls /var/www/midterm-app`

---

## 🎯 PHASE 3: SIMPLIFIED TERMINAL MAP

| Phase | Terminal | What to Do |
|-------|----------|-----------|
| Build Docker Image | 🖥️ LOCAL | `docker build ...` |
| Push to Docker Hub | 🖥️ LOCAL | `docker push ...` |
| SSH to AWS | 🖥️ LOCAL | `ssh -i Midterm.pem ...` |
| Deploy Containers | 🌐 AWS | `bash scripts/docker-deploy.sh` |
| Check Status | 🌐 AWS | `docker-compose ps` |
| Test App | 🌐 AWS | `curl http://localhost:3000` |
| Verify All | 🌐 AWS | `bash scripts/docker-verify.sh` |

---

## 🚀 READY?

**Khi bạn:**
- ✅ Hiểu Local vs AWS terminal
- ✅ Có Midterm.pem key
- ✅ Có AWS IP: 44.207.47.147
- ✅ Docker installed locally

**Thì bạn sẵn sàng bắt đầu Phase 3! 🎉**

---

**Pro Tip:** Mở 2 terminal tabs:
1. Tab 1: Local (for build)
2. Tab 2: SSH to AWS (for deploy)

Như thế bạn có thể dễ dàng switch giữa 2 environments!


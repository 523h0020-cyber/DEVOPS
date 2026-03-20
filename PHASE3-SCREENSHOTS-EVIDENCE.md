# 📸 PHASE 3 - CHỨNG MINH RÕ RÀNG (Proof of Execution)

> Hướng dẫn chụp ảnh chứng minh Phase 3 Docker hoạt động

---

## 🎯 Mục tiêu

Chứng minh rằng:
- ✅ Docker image được build thành công (~205MB)
- ✅ Push lên Docker Hub thành công
- ✅ Docker containers chạy trên AWS (HEALTHY)
- ✅ App respond qua API
- ✅ MongoDB có dữ liệu (11 sản phẩm)
- ✅ Data persist qua container restart
- ✅ Domain 523h0020.site hoạt động

---

## 📸 CHỨNG MINH CỤ THỂ (19 Screenshots)

### ✨ PHẦN A: LOCAL BUILD (4 screenshots)

#### Screenshot A1: Docker Installed
```bash
docker --version
```
**Chụp**: Terminal hiển thị Docker version ✓

#### Screenshot A2: Build Output
```bash
cd sample-midterm-project/sample-midterm-node.js-project
docker build -t your-username/midterm-app:1.0.0 .
```
**Chụp**: Terminal cuối build hiển thị `=> naming to docker.io/your-username/midterm-app:1.0.0` ✓

#### Screenshot A3: Image Size ~205MB
```bash
docker images | grep midterm-app
```
**Chụp**: Output showing:
```
your-username/midterm-app  1.0.0  abc123  45s  205MB  ← IMAGE SIZE
```

#### Screenshot A4: Image Works
```bash
docker run --rm your-username/midterm-app:1.0.0 node --version
```
**Chụp**: Output showing Node.js version ✓

### 🚀 PHẦN B: DOCKER HUB (2 screenshots)

#### Screenshot B1: Login Succeeded
```bash
docker login -u your-username
```
**Chụp**: Output hiển thị `Login Succeeded` ✓

#### Screenshot B2: Push Complete
```bash
docker push your-username/midterm-app:1.0.0
```
**Chụp**: Terminal showing:
```
1.0.0: digest: sha256:abcd1234...
latest: digest: sha256:abcd1234...
```

#### Screenshot B3: Docker Hub Page
**Truy cập**: `https://hub.docker.com/r/your-username/midterm-app`
**Chụp**: Browser showing:
- Image name, Tags (1.0.0, latest)
- Size: ~205MB
- Last pushed: [today]

### 🌐 PHẦN C: AWS DEPLOYMENT (8 screenshots)

#### Screenshot C1: SSH to AWS
```bash
ssh -i Midterm.pem ubuntu@44.207.47.147
```
**Chúp**: Terminal prompt `ubuntu@ip-172-31-xx-xx:~$` ✓

#### Screenshot C2: App Directory
```bash
cd /var/www/midterm-app
ls -la
```
**Chụp**: Directory listing showing:
- docker-compose.yml
- .env.docker
- scripts/ folder

#### Screenshot C3: Docker Initialized
```bash
bash scripts/docker-init-aws.sh
```
**Chụp**: Terminal output ending with `✅ INITIALIZATION COMPLETE!` ✓

#### Screenshot C4: Containers Deployed
```bash
bash scripts/docker-deploy.sh
```
**Chụp**: Output showing:
```
midterm-app  your-username/midterm-app:latest  Up 5 seconds (healthy)
mongodb      mongo:8.0-alpine                   Up 5 seconds (healthy)
```

**Key**: Both say "(healthy)" ✓

#### Screenshot C5: Docker Compose Status
```bash
docker-compose ps
```
**Chụp**: Output clearly showing:
```
NAME        IMAGE                      STATUS
mongodb     mongo:8.0-alpine           Up ... (healthy)  
midterm-app your-username/midterm-app  Up ... (healthy)
```

#### Screenshot C6: Web App Responds
```bash
curl http://localhost:3000 | head -40
```
**Chụp**: HTML output showing:
```html
<!DOCTYPE html>
...
<title>Midterm App - Product Management</title>
...
<tr>
  <td>iPhone 14 Pro Max</td>
  <td>$1099</td>
  ...
</tr>
```

#### Screenshot C7: MongoDB Data
```bash
docker-compose exec mongodb mongosh
> use products_db
> db.products.countDocuments()
```
**Chụp**: MongoDB shell showing `11` ✓

#### Screenshot C8: Nginx Configured
```bash
bash scripts/docker-nginx-proxy.sh
```
**Chụp**: Output showing:
```
✅ Nginx configuration created
✅ Nginx configuration is valid
✅ Nginx restarted
```

### ✅ PHẦN D: VERIFICATION (3 screenshots)

#### Screenshot D1: Full Verification
```bash
bash scripts/docker-verify.sh
```
**Chụp**: Key lines showing:
```
✅ Docker version...
✅ Docker Compose...
✅ Running containers [both HEALTHY]
✅ MongoDB healthy
✅ Web app responding
✅ Nginx running
```

#### Screenshot D2: Health Check
```bash
./docker-manage.sh health
```
**Chụp**: Output showing:
```
✅ MongoDB: HEALTHY
✅ Web App: HEALTHY
```

#### Screenshot D3: Nginx Proxy Test
```bash
curl -k https://523h0020.site | head -40
```
**Chụp**: HTML response với products (same as C6) ✓

### 💾 PHẦN E: DATA PERSISTENCE (2 screenshots)

#### Screenshot E1: Backup Created
```bash
./docker-manage.sh backup
```
**Chụp**: Output showing:
```
✅ Backup saved: ./backups/mongodb_backup_20260320_XXXXXX.tar.gz
-rw-r--r-- ... mongodb_backup_20260320_XXXXXX.tar.gz
```

#### Screenshot E2: Browser Test
**URL**: `https://523h0020.site`
**Chụp**: Browser showing:
- App title and table
- Products displayed (iPhone, MacBook, etc.)
- Add/Edit/Delete buttons working

---

## 📋 CHECKLIST: 19 Screenshots

```
LOCAL BUILD:
☐ A1: docker --version
☐ A2: Build output (successful)
☐ A3: Image size ~205MB
☐ A4: Node.js in container

DOCKER HUB:
☐ B1: docker login succeeded
☐ B2: Push complete
☐ B3: Docker Hub page

AWS DEPLOYMENT:
☐ C1: SSH connected
☐ C2: App directory structure
☐ C3: Docker initialized
☐ C4: Containers deployed (healthy)
☐ C5: docker-compose ps (both healthy)
☐ C6: Web app HTML response
☐ C7: MongoDB count = 11
☐ C8: Nginx configured

VERIFICATION:
☐ D1: Full verification script
☐ D2: Health check (all green)
☐ D3: Domain via HTTPS working

DATA PERSISTENCE:
☐ E1: Backup file created
☐ E2: Browser test on domain
```

**Total: 19 Screenshots** ✅

---

## 🚀 EASY MODE: Run These Commands in Order

```bash
# LOCAL MACHINE
# ============

# 1. Build
cd ~/Projects/DevOPs/Midterm/DEVOPS/sample-midterm-project/sample-midterm-node.js-project
docker build -t your-username/midterm-app:1.0.0 .
# 📸 Screenshot: Build output

# 2. Verify image
docker images | grep midterm-app
# 📸 Screenshot: Show 205MB

# 3. Push
docker login
docker push your-username/midterm-app:1.0.0
# 📸 Screenshot: Push complete


# AWS SERVER
# ==========

ssh -i Midterm.pem ubuntu@44.207.47.147

# 4. Deploy
cd /var/www/midterm-app
bash scripts/docker-init-aws.sh
# 📸 Screenshot: Init complete

bash scripts/docker-deploy.sh
# 📸 Screenshot: Containers healthy

# 5. Check status
docker-compose ps
# 📸 Screenshot: Both marked (healthy)

# 6. Test app
curl http://localhost:3000 | head -20
# 📸 Screenshot: HTML with products

# 7. Check data
docker-compose exec mongodb mongosh
use products_db
db.products.countDocuments()
# 📸 Screenshot: Output = 11

# 8. Nginx
bash scripts/docker-nginx-proxy.sh
# 📸 Screenshot: Nginx complete

# 9. Verify
bash scripts/docker-verify.sh
# 📸 Screenshot: All green checks

./docker-manage.sh health
# 📸 Screenshot: Health status

# 10. Test domain
curl -k https://523h0020.site | head -20
# 📸 Screenshot: HTML response
```

---

## 🎬 BROWSER TEST

**URL**: `https://523h0020.site`

**Bạn sẽ thấy:**
1. Title: "Midterm App - Product Management"
2. Button: "Create New Product"
3. Table with columns:
   - Product Name
   - Price
   - Color
   - Actions (Edit/Delete)
4. 11 rows of products

🎬 **Record video or take screenshot**

---

## 📊 METRICS ĐỂ CHỨNG MINH

| Metric | Giá Trị | Evidence |
|--------|--------|----------|
| Image Size | ~205MB | A3 |
| Build Time | ~45s | A2 |
| Container Status | HEALTHY | C4, C5 |
| Products in DB | 11 | C7 |
| API Response Time | <100ms | C6 |
| Domain Response | 200 OK | D3 |
| Nginx Status | Running | D1 |
| MongoDB Status | Running | C7 |

---

## 💡 TIPS

1. **Screenshots Tools:**
   - Windows: Win + Shift + S (Snip)
   - Mac: Cmd + Shift + 4
   - Linux: PrintScrn or gnome-screenshot

2. **Copy Output:**
   ```bash
   # Copy to clipboard (Linux)
   docker-compose ps | xclip -selection clipboard
   
   # Or just select & Ctrl+C in terminal
   ```

3. **Full Terminal Output:**
   ```bash
   # Capture everything
   docker-compose ps | tee output.txt
   ```

4. **Browser Screenshot:**
   - F12 → Device Toolbar
   - Capture full page
   - Show URL bar in screenshot

---

## 🎯 FINAL CHECKLIST

Before declaring Phase 3 complete:

- [ ] All 19 screenshots taken
- [ ] Images clearly show Terminal + Output
- [ ] Include date/time if visible
- [ ] Show command being run
- [ ] Show clear success indicators:
  - "✅" marks
  - "(healthy)" status
  - HTML response
  - "11" products count

---

## 📂 Organize Screenshots

**Folder Structure:**
```
Phase3_Screenshots/
├── A_Build/
│   ├── A1_docker_version.png
│   ├── A2_build_output.png
│   ├── A3_image_size.png
│   └── A4_node_test.png
├── B_Hub/
│   ├── B1_login.png
│   ├── B2_push.png
│   └── B3_hub_page.png
├── C_Deploy/
│   ├── C1_ssh.png
│   ├── C2_directory.png
│   ├── C3_init.png
│   ├── C4_deploy.png
│   ├── C5_status.png
│   ├── C6_curl.png
│   ├── C7_mongodb.png
│   └── C8_nginx.png
├── D_Verify/
│   ├── D1_verify_script.png
│   ├── D2_health.png
│   └── D3_domain.png
└── E_Persistence/
    ├── E1_backup.png
    └── E2_browser.png
```

---

## ✨ PHASE 3 COMPLETE PROOF!

Khi bạn có tất cả 19 screenshots, bạn đã chứng minh:

✅ Docker image được build thành công
✅ Image tối ưu (~205MB)
✅ Đẩy lên Docker Hub
✅ Containers chạy trên AWS
✅ Ứng dụng hoạt động (API responds)
✅ Database có dữ liệu
✅ Nginx proxy hoạt động
✅ Domain accessible via HTTPS
✅ Tất cả services HEALTHY

**Phase 3: PRODUCTION READY! 🚀**

---

**Created**: 2026-03-20  
**Purpose**: Proof of Execution Documentation  
**Status**: ✅ Ready to Deploy

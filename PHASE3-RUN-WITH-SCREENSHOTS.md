# Phase 3 - Docker Deployment: Step-by-Step với Chứng Minh

> Hướng dẫn chạy Phase 3 Docker với screenshots/chứng minh từng bước

---

## 📸 PHẦN 1: BUILD ĐỀN HÌNH (Local Machine)

### Step 1.1: Kiểm tra Docker

**Lệnh:**
```bash
docker --version
docker-compose --version
```

**Kết quả dự kiến:**
```
Docker version 20.10.x, build xxxxxx
Docker Compose version v2.x.x, build xxxxxx
```

**Chứng minh**: Screenshot hiển thị version

---

### Step 1.2: Navigate & Build Image

**Lệnh:**
```bash
cd ~/Projects/DevOPs/Midterm/DEVOPS
cd sample-midterm-project/sample-midterm-node.js-project

# Xem file hiện tại
ls -la
# Sẽ thấy: Dockerfile, package.json, main.js
```

**Kết quả dự kiến:**
```
-rw-r--r--  1 user  staff   xxx Feb 20 main.js
-rw-r--r--  1 user  staff   xxx Feb 20 package.json
-rw-r--r--  1 user  staff   xxx Feb 20 Dockerfile
-rw-r--r--  1 user  staff   xxx Feb 20 .dockerignore
```

**Chứng minh**: Screenshot folder structure

---

### Step 1.3: Build Docker Image

**Lệnh:**
```bash
docker build -t your-docker-username/midterm-app:1.0.0 .
```

**Quá trình Build bạn sẽ thấy:**
```
[+] Building 45.2s (13/13) FINISHED
 => [internal] load build definition from Dockerfile
 => [builder] FROM node:20-alpine
 => [builder] WORKDIR /app
 => [builder] COPY package*.json ./
 => [builder] RUN npm ci --only=production
 => [stage-1] FROM node:20-alpine
 => [stage-1] WORKDIR /app
 => [stage-1] COPY --from=builder /app/node_modules ./node_modules
 => [stage-1] COPY --chown=nodejs:nodejs . .
 => [stage-1] EXPOSE 3000
 => => naming to docker.io/your-username/midterm-app:1.0.0
```

**Chứng minh**: Screenshot build output

---

### Step 1.4: Xác Minh Image Được Tạo

**Lệnh:**
```bash
docker images | grep midterm-app
```

**Kết quả dự kiến:**
```
your-username/midterm-app   1.0.0     abc123def456    45 seconds ago   205MB
your-username/midterm-app   latest    abc123def456    45 seconds ago   205MB
```

**Chứng minh**: Screenshot showing image size ~205MB

---

### Step 1.5: Test Image Chạy

**Lệnh:**
```bash
docker run --rm your-username/midterm-app:1.0.0 node --version
```

**Kết quả dự kiến:**
```
v20.11.x
```

**Chứng minh**: Screenshot Node.js version output

---

### Step 1.6: Test App Container

**Lệnh:**
```bash
# Chạy container 5 giây rồi dừng
timeout 5 docker run --rm -p 3000:3000 your-username/midterm-app:1.0.0 || true
```

**Kết quả dự kiến:**
```
Server listening on port http://localhost:3000 — hostname: xxxxxxxx
```

**Chứng minh**: Screenshot showing "Server listening on port"

---

## 📸 PHẦN 2: PUSH SANG DOCKER HUB

### Step 2.1: Login to Docker Hub

**Lệnh:**
```bash
docker login -u your-docker-username
# Nhập password khi được yêu cầu
```

**Kết quả dự kiến:**
```
Login Succeeded
```

**Chứng minh**: Screenshot "Login Succeeded"

---

### Step 2.2: Push Image

**Lệnh:**
```bash
docker push your-username/midterm-app:1.0.0
docker push your-username/midterm-app:latest
```

**Quá trình Push:**
```
The push refers to repository [docker.io/your-username/midterm-app]
abc123def456: Pushed
def789ghi012: Pushed
jkl345mno678: Pushed
1.0.0: digest: sha256:abcd1234efgh5678ijkl9010mnop1234qrst5678uvwx9012yz sha256 size: 2413
latest: digest: sha256:abcd1234efgh5678ijkl9010mnop1234qrst5678uvwx9012yz sha256 size: 2413
```

**Chứng minh**: Screenshot push output

---

### Step 2.3: Verify on Docker Hub

**Truy cập:**
```
https://hub.docker.com/r/your-username/midterm-app
```

**Bạn sẽ thấy:**
- Image name: `your-username/midterm-app`
- Tags: `1.0.0`, `latest`
- Size: ~205MB
- Last pushed: [current date/time]

**Chứng minh**: Screenshot Docker Hub page

---

## 📸 PHẦN 3: DEPLOY KỀN AWS

### Step 3.1: SSH vào AWS Server

**Lệnh:**
```bash
ssh -i Midterm.pem ubuntu@44.207.47.147
```

**Kết quả dự kiến:**
```
ubuntu@ip-172-31-xx-xx:~$
```

**Chứng minh**: Screenshot SSH prompt

---

### Step 3.2: Navigate to App Directory

**Lệnh:**
```bash
cd /var/www/midterm-app
ls -la
```

**Kết quả dự kiến:**
```
total xxx
drwxr-xr-x  x ubuntu ubuntu    xxx Mar 20 10:45 .
drwxr-xr-x  x root   root      xxx Mar 20 10:00 ..
-rw-r--r--  1 ubuntu ubuntu    xxx Mar 20 10:45 docker-compose.yml
-rw-r--r--  1 ubuntu ubuntu    xxx Mar 20 10:45 .env.docker
drwxr-xr-x  x ubuntu ubuntu    xxx Mar 20 10:45 scripts/
drwxr-xr-x  x ubuntu ubuntu    xxx Mar 20 10:45 src/
```

**Chứng minh**: Screenshot directory listing

---

### Step 3.3: Initialize Docker (First Time)

**Lệnh:**
```bash
bash scripts/docker-init-aws.sh
```

**Output Mong Đợi:**
```
==================================================
🐳 DOCKER INITIALIZATION (AWS Server)
==================================================

1️⃣  Checking system...
✅ Running on: Ubuntu 24.04 LTS
...
✅ Docker: Docker version 24.0.x, build xxxx
✅ Docker Compose: Docker Compose version 2.x.x
✅ ubuntu user added to docker group
✅ Directories created
✅ .env.docker created
✅ Docker daemon running
✅ Disk space: 50GB free

==================================================
✅ INITIALIZATION COMPLETE!
==================================================
```

**Chứng minh**: Screenshot initialization output

---

### Step 3.4: Edit Environment File

**Lệnh:**
```bash
nano .env.docker
```

**Sửa để có:**
```env
DOCKER_HUB_USERNAME=your-username
IMAGE_VERSION=1.0.0
NODE_ENV=production
PORT=3000
MONGO_URI=mongodb://mongodb:27017/products_db
DOMAIN=523h0020.site
EMAIL=lenamgiang5@gmail.com
```

**Chứng minh**: Screenshot .env.docker content

---

### Step 3.5: Deploy Containers

**Lệnh:**
```bash
bash scripts/docker-deploy.sh
```

**Output Mong Đợi:**
```
==================================================
🐳 DOCKER COMPOSE DEPLOYMENT
==================================================

1️⃣  Checking prerequisites...
✅ Docker: Docker version 24.0.x, build xxxx
✅ Docker Compose: Docker Compose version 2.24.x

2️⃣  Creating directories...
✅ Directories created

3️⃣  Checking docker-compose.yml...
✅ docker-compose.yml found

4️⃣  Loading environment...
✅ .env.docker loaded

5️⃣  Pulling images from registry...
Pulling mongodb    ... done
Pulling web        ... done
✅ Images pulled

6️⃣  Starting containers...
Creating mongodb ... done
Creating midterm-app ... done
✅ Containers started

7️⃣  Waiting for services to be ready...
✅ Services should be ready

8️⃣  Service status:
NAME            IMAGE                              STATUS
mongodb         mongo:8.0-alpine                   Up 5 seconds (healthy)
midterm-app     your-username/midterm-app:latest  Up 5 seconds (healthy)

9️⃣  Health checks:
✅ MongoDB: HEALTHY
✅ Web App: HEALTHY

🔟 Recent logs:
[MongoDB logs...]
[Web app logs...]

==================================================
✅ DEPLOYMENT COMPLETE!
==================================================

Commands:
  View logs:     docker-compose logs -f
  Stop:          docker-compose stop
  Restart:       docker-compose restart
  Remove:        docker-compose down
```

**Chứng minh**: Screenshot deployment output with "HEALTHY" status

---

### Step 3.6: Kiểm tra Containers Chạy

**Lệnh:**
```bash
docker-compose ps
```

**Kết quả dự kiến:**
```
NAME         IMAGE                              STATUS
mongodb      mongo:8.0-alpine                   Up 1 minute (healthy)
midterm-app  your-username/midterm-app:latest  Up 1 minute (healthy)
```

**Chứng minh**: Screenshot showing both containers HEALTHY

---

### Step 3.7: Test Web App

**Lệnh:**
```bash
curl http://localhost:3000 | head -50
```

**Kết quả dự kiến:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Midterm App - Product Management</title>
    <link rel="stylesheet" href="/css/styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
...
<table class="table">
    <thead>
        <tr>
            <th>Product Name</th>
            <th>Price</th>
            <th>Color</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>iPhone 14 Pro Max</td>
            <td>$1099</td>
            <td>space-black</td>
            <td><a href="/products/xxx/edit">Edit</a> | <a href="/products/xxx/delete">Delete</a></td>
        </tr>
```

**Chứng minh**: Screenshot HTML output with products

---

### Step 3.8: Test MongoDB Connection

**Lệnh:**
```bash
docker-compose exec mongodb mongosh
```

**Trong mongosh:**
```javascript
use products_db
db.products.countDocuments()
```

**Kết quả dự kiến:**
```
products_db> db.products.countDocuments()
11
```

**Chứng minh**: Screenshot MongoDB shell and count

---

### Step 3.9: Configure Nginx

**Lệnh:**
```bash
bash scripts/docker-nginx-proxy.sh
```

**Output Mong Đợi:**
```
==================================================
🌐 NGINX → DOCKER PROXY CONFIG
==================================================

Creating Nginx configuration...
Domain: 523h0020.site
✅ Nginx configuration created
✅ Symlink already exists
✅ Nginx configuration is valid
Removing default Nginx config...
✅ Default config removed
Restarting Nginx...
✅ Nginx restarted

==================================================
✅ NGINX CONFIGURATION COMPLETE!
==================================================

Proxy setup:
  TCP 80   → HTTPS redirect
  TCP 443  → http://localhost:3000 (Docker container)

Test with:
  curl https://523h0020.site
  curl -k https://localhost
```

**Chứng minh**: Screenshot Nginx configuration complete

---

### Step 3.10: Verify Deployment

**Lệnh:**
```bash
bash scripts/docker-verify.sh
```

**Output Mong Đợi:**
```
==================================================
✅ DOCKER DEPLOYMENT VERIFICATION
==================================================

1️⃣  Checking Docker installation...
✅ Docker version 24.0.x, build xxxx

2️⃣  Checking Docker Compose...
✅ Docker Compose version 2.24.x, build xxxxx

3️⃣  Checking running containers...
NAME         IMAGE                              STATUS
mongodb      mongo:8.0-alpine                   Up About a minute (healthy)
midterm-app  your-username/midterm-app:latest  Up About a minute (healthy)

4️⃣  Checking MongoDB...
✅ MongoDB healthy (Products: 11)

5️⃣  Checking web application...
✅ Web app responding (HTML received)

6️⃣  Checking Nginx...
✅ Nginx running

7️⃣  Checking port bindings...
  tcp        0      0 0.0.0.0:80             0.0.0.0:*               LISTEN
  tcp        0      0 0.0.0.0:443            0.0.0.0:*               LISTEN
  tcp        0      0 127.0.0.1:3000         0.0.0.0:*               LISTEN
  tcp        0      0 127.0.0.1:27017        0.0.0.0:*               LISTEN

8️⃣  Checking volumes...
metadata_data  local      /var/lib/midterm-app/mongodb

9️⃣  Checking disk usage...
Images         6        2.5GB      205MB
Containers     2        45MB       32MB
Local Volumes  1        50MB

🔟 Recent logs:
  MongoDB: Connected
  Web app: Server listening on port 3000

==================================================
✅ VERIFICATION COMPLETE!
==================================================
```

**Chứng minh**: Screenshot verification output - ALL GREEN ✅

---

## 📸 PHẦN 4: TEST TRÊN PRODUCTION DOMAIN

### Step 4.1: Test Domain via Nginx

**Từ Local Machine:**
```bash
curl -k https://523h0020.site | head -100
```

**Hoặc mở browser:**
```
https://523h0020.site
```

**Kết quả dự kiến:**
```html
<!DOCTYPE html>
<html>
...
<h1>Midterm App - Product Management</h1>
<table class="table">
    [Products displayed here]
</table>
```

**Chứng minh**: Screenshot browser showing 523h0020.site with product table

---

### Step 4.2: Test Upload File

**Upload ảnh thông qua form trên giao diện**

**Quy trình:**
1. Mở https://523h0020.site
2. Click "Create New Product"
3. Upload ảnh qua form
4. Submit

**Kết quả dự kiến:**
- File được lưu vào container volume
- File tồn tại sau khi restart container
- File hiển thị trong product list

**Chứng minh**: Screenshot file upload success

---

### Step 4.3: Test Data Persistence

**Trên AWS Server:**

**Dừng container:**
```bash
docker-compose stop web
```

**Kiểm tra data vẫn tồn tại:**
```bash
curl http://localhost:3000
# Sẽ có lỗi (web stopped)

# Nhưng data vẫn lưu:
ls -la public/uploads/
# Sẽ thấy uploaded files
```

**Khởi động lại:**
```bash
docker-compose up -d web
sleep 5

curl http://localhost:3000
# HTML response với data cũ
```

**Chứng minh**: Screenshots showing:
- Web stopped (curl error)
- Uploads folder has files
- Web restarted
- Same data present

---

## 📸 PHẦN 5: MONITORING & LOGS

### Step 5.1: View Real-time Logs

**Lệnh:**
```bash
docker-compose logs -f
```

**Kết quả:**
```
mongodb   | {"t":{"$date":"2026-03-20T10:45:22.123Z"}...
midterm-app | Server listening on port http://localhost:3000
midterm-app | Connected to MongoDB — using mongodb as data source
midterm-app | GET / 200 123ms
midterm-app | GET /css/styles.css 200 5ms
midterm-app | GET /products 200 45ms
```

**Chứng minh**: Screenshot live logs

---

### Step 5.2: Health Status

**Lệnh:**
```bash
./docker-manage.sh health
```

**Output:**
```
🏥 Health Check:

MongoDB:
  ✅ Healthy

Web App:
  ✅ Healthy

Container stats:
CONTAINER   CPU%     MEM USAGE / LIMIT
mongodb     0.2%     156MB / 4GB
midterm-app 0.1%     45MB / 512MB
```

**Chứng minh**: Screenshot health status all green

---

### Step 5.3: Database Backup

**Lệnh:**
```bash
./docker-manage.sh backup
```

**Output:**
```
💾 Backing up MongoDB...
✅ Backup saved: ./backups/mongodb_backup_20260320_104530.tar.gz

-rw-r--r-- 1 ubuntu ubuntu 5.2M Mar 20 10:45 mongodb_backup_20260320_104530.tar.gz
```

**Chứng minh**: Screenshot backup file creation

---

## 📸 PHẦN 6: MANAGEMENT COMMANDS

### Step 6.1: View All Containers

**Lệnh:**
```bash
docker-compose ps
```

**Output:**
```
NAME         IMAGE                                   STATUS
mongodb      mongo:8.0-alpine                        Up 10 minutes (healthy)
midterm-app  your-username/midterm-app:1.0.0      Up 10 minutes (healthy)
```

---

### Step 6.2: Check Logs

**Lệnh:**
```bash
./docker-manage.sh logs web
```

**Output:**
```
Server listening on port http://localhost:3000
Connected to MongoDB — using mongodb as data source
GET / HTTP/1.1 200
GET /products HTTP/1.1 200
```

---

### Step 6.3: MongoDB Shell Access

**Lệnh:**
```bash
./docker-manage.sh db-shell
```

**Trong shell:**
```javascript
use products_db
db.products.find().pretty()
```

---

## ✅ CHECKLIST CHỨNG MINH

Hãy chụp ảnh các bước sau:

- [ ] Step 1.1: Docker version
- [ ] Step 1.3: Docker build output
- [ ] Step 1.4: docker images output (~205MB)
- [ ] Step 1.5: Node version in container
- [ ] Step 2.1: "Login Succeeded" 
- [ ] Step 2.2: Push to Docker Hub
- [ ] Step 2.3: Docker Hub page showing image
- [ ] Step 3.1: SSH into AWS
- [ ] Step 3.3: docker-init-aws.sh output
- [ ] Step 3.5: docker-deploy.sh shows containers HEALTHY
- [ ] Step 3.6: docker-compose ps (both HEALTHY)
- [ ] Step 3.7: curl localhost:3000 (HTML output)
- [ ] Step 3.8: MongoDB countDocuments = 11
- [ ] Step 3.9: Nginx configuration complete
- [ ] Step 3.10: docker-verify.sh (ALL GREEN ✅)
- [ ] Step 4.1: Browser showing 523h0020.site
- [ ] Step 4.2: File upload success
- [ ] Step 5.1: docker-compose logs -f
- [ ] Step 5.2: docker-manage.sh health (all healthy)
- [ ] Step 5.3: Backup file created

---

## 📝 Summary Screenshots to Collect

### Local Build Evidence
1. Docker build complete (205MB)
2. Image on Docker Hub
3. Push successful

### AWS Deployment Evidence
4. All containers HEALTHY
5. curl returning HTML with products
6. MongoDB has 11 documents
7. Domain accessible (523h0020.site)
8. Health check passing
9. Backup created

**Total: ~15-20 screenshots² yang chứng minh Phase 3 hoọc động**

---

**Ready to run Phase 3!** 🚀


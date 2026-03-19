# AWS DEPLOYMENT GUIDE - 523h0020.site

## 📋 Công Cụ & Yêu Cầu

- **Domain**: 523h0020.site
- **Email**: lenamgiang5@gmail.com
- **Port**: 3000 (Node.js) → 80/443 (Nginx)
- **Database**: MongoDB (dữ liệu persistent)
- **Server**: Ubuntu 24.04 LTS trên AWS EC2

---

## 🚀 DEPLOYMENT TỰ ĐỘNG (Khuyến nghị)

### Bước 1: Tạo EC2 Instance
```bash
# AWS Console → EC2 → Launch Instance
- AMI: Ubuntu Server 24.04 LTS
- Instance Type: t3.medium (hoặc t4g.medium)
- Storage: 30GB+
- Security Group: Allow SSH (22), HTTP (80), HTTPS (443)
```

### Bước 2: SSH vào server
```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

### Bước 3: Clone repo & deploy
```bash
git clone https://github.com/523h0020-cyber/DEVOPS.git
cd DEVOPS/scripts
sudo bash deploy-to-aws.sh
```

**Script sẽ tự động:**
- ✅ Cài Node.js 20 LTS
- ✅ Cài PM2 (Process Manager)
- ✅ Cài Nginx (Reverse Proxy)
- ✅ Cài MongoDB 8.0
- ✅ Deploy ứng dụng
- ✅ Cấu hình SSL/HTTPS
- ✅ Setup MongoDB backup hàng ngày
- ✅ Cấu hình domain 523h0020.site

---

## 🔄 DEPLOYMENT TỪNG BƯỚC

Nếu muốn kiểm soát từng phase:

### Phase 1: Server Setup
```bash
sudo bash setup.sh
```
- Cập nhật hệ thống
- Cài Node.js 20, PM2, Nginx
- Tạo thư mục project

### Phase 2: Application & Database
```bash
sudo bash phase2.sh
```
- Cài MongoDB 8.0
- Clone code từ GitHub
- Cài npm dependencies
- Khởi động ứng dụng với PM2
- Cấu hình Nginx reverse proxy

### Phase 3: SSL & Domain
```bash
sudo bash phase3-ssl-setup.sh
```
- Lấy SSL certificate từ Let's Encrypt
- Cấu hình domain 523h0020.site
- Setup auto-renew certificate
- Enable HTTPS

### Phase 4: MongoDB Backup
```bash
sudo bash -c 'cp backup-mongodb.sh /usr/local/bin/ && chmod +x /usr/local/bin/backup-mongodb.sh'

# Thêm vào crontab (backup hàng ngày lúc 2 AM)
sudo crontab -e
# Thêm dòng: 0 2 * * * /usr/local/bin/backup-mongodb.sh >> /var/log/mongodb-backup.log 2>&1
```

---

## 🛡️ ĐẢM BẢO KHÔNG MẤT DỮ LIỆU

### 1. **MongoDB Persistent Storage**
- Dữ liệu lưu ở `/var/lib/mongodb` (SSD volume)
- Tự động khôi phục nếu server restart

### 2. **PM2 Auto-restart**
- Nếu app crash, PM2 tự động restart
- Giới hạn 500MB RAM, tự động restart nếu vượt

### 3. **Daily Backup**
```bash
# Backup chạy tự động hàng ngày lúc 2 AM
# Lưu ở: /var/backups/mongodb/backup_YYYYMMDD_HHMMSS.tar.gz
# Giữ lại 7 ngày gần nhất

# View backups
ls -lh /var/backups/mongodb/

# Restore từ backup
sudo bash restore-mongodb.sh /var/backups/mongodb/backup_20240319_020000.tar.gz
```

### 4. **Nginx Reverse Proxy**
- Ghi nhận HTTPS headers properly
- Load balance nếu chạy multiple instances

---

## 📝 CẤU HÌNH THỦ CÔNG

### 1. Cập nhật .env file
```bash
cd /var/www/midterm-app/src/sample-midterm-project/sample-midterm-node.js-project
nano .env
```

```env
NODE_ENV=production
PORT=3000
MONGO_URI=mongodb://localhost:27017/products_db
```

### 2. Cập nhật domain DNS
Chỉ A record của `523h0020.site` tới public IP của EC2:

```
Type: A
Name: 523h0020.site
Value: <EC2 Public IP>

Type: A  
Name: www.523h0020.site
Value: <EC2 Public IP>
```

### 3. Xác minh SSL
```bash
sudo certbot certificates
```

---

## 🔧 QUẢN LÝ ỨNG DỤNG

### Kiểm tra trạng thái
```bash
# Toàn bộ health check
sudo bash health-check.sh

# Hoặc chi tiết:
pm2 status                          # Trạng thái app
pm2 logs midterm-app               # Xem logs
sudo systemctl status mongod       # MongoDB status
sudo systemctl status nginx        # Nginx status
```

### Kiểm soát ứng dụng
```bash
pm2 start midterm-app              # Khởi động
pm2 stop midterm-app               # Dừng
pm2 restart midterm-app            # Restart
pm2 delete midterm-app             # Xóa
```

### Kiểm soát MongoDB
```bash
sudo systemctl start mongod        # Khởi động
sudo systemctl stop mongod         # Dừng
sudo systemctl restart mongod      # Restart
```

### Kiểm soát Nginx
```bash
sudo systemctl start nginx         # Khởi động
sudo systemctl stop nginx          # Dừng
sudo systemctl restart nginx       # Restart
sudo nginx -t                      # Test config
```

---

## 📦 BACKUP & RESTORE

### Backup thủ công
```bash
sudo bash backup-mongodb.sh
```

### Restore từ backup
```bash
sudo bash restore-mongodb.sh /var/backups/mongodb/backup_20240319_020000.tar.gz
```

### View backups
```bash
ls -lh /var/backups/mongodb/
tail -f /var/log/mongodb-backup.log
```

---

## 🚨 TROUBLESHOOTING

### App không chạy
```bash
pm2 logs midterm-app               # Xem error
pm2 delete midterm-app
npm install                        # Reinstall dependencies
pm2 start ecosystem.config.js      # Start lại
```

### MongoDB không chạy
```bash
sudo systemctl status mongod       # Check status
sudo systemctl restart mongod      # Restart
mongo                              # Test connection
```

### Nginx không hoạt động
```bash
sudo nginx -t                      # Test config
sudo systemctl restart nginx       # Restart
sudo tail -f /var/log/nginx/error.log  # View errors
```

### Máy hết storage
```bash
df -h                              # Check disk usage
sudo rm -rf /var/backups/mongodb/backup_old*  # Remove old backups
sudo apt-get clean                 # Clean apt cache
```

---

## 🔐 SECURITY CHECKLIST

- [x] Firewall chỉ mở port 22, 80, 443
- [x] SSH key authentication (não password)
- [x] HTTPS/SSL enabled
- [x] MongoDB không expose ra internet
- [x] Regular backups
- [x] PM2 auto-restart
- [x] System logs monitoring

---

## 📊 THÔNG TIN TRUY CẬP

| Thành phần | URL/Port | Trạng thái |
|-----------|---------|-----------|
| Website | https://523h0020.site | Public |
| API | https://523h0020.site/products | Public |
| Admin SSH | Port 22 | Restricted |
| MongoDB | localhost:27017 | Internal only |
| Nginx | Port 80/443 | Public |

---

## 💾 FILE STRUCTURE

```
/var/www/midterm-app/
├── src/                          # Application code
│   └── sample-midterm-project/
│       └── sample-midterm-node.js-project/
│           ├── main.js
│           ├── package.json
│           ├── .env             # Load từ environment
│           ├── models/
│           ├── routes/
│           ├── controllers/
│           ├── services/
│           ├── views/
│           └── public/
│               └── uploads/      # User uploads
├── docs/                         # Documentation
└── scripts/                      # Deployment scripts

/var/backups/mongodb/             # Database backups
/var/log/mongodb-backup.log       # Backup logs
~/.pm2/                           # PM2 config & logs
/etc/letsencrypt/live/            # SSL certificates
/etc/nginx/sites-available/       # Nginx configs
```

---

**Cập nhật lần cuối**: 19 tháng 3, 2026

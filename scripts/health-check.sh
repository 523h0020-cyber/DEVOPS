#!/bin/bash
# Health Check Script - Monitor application and database status

echo "================================================="
echo "🏥 HEALTH CHECK - $(date)"
echo "================================================="

# Check Node.js Application
echo ""
echo "📱 Application Status:"
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 not installed"
elif pm2 show midterm-app 2>/dev/null | grep -q "online"; then
    echo "✅ App Status: ONLINE"
    pm2 show midterm-app 2>/dev/null | head -5
else
    echo "❌ App Status: NOT RUNNING or offline"
    echo "   Restart with: pm2 start main.js --name midterm-app"
fi

# Check MongoDB Status
echo ""
echo "🗄️  MongoDB Status:"
if systemctl is-active --quiet mongod; then
    echo "✅ MongoDB: RUNNING"
    MONGO_SIZE=$(du -sh /var/lib/mongodb 2>/dev/null | awk '{print $1}')
    echo "   Data size: $MONGO_SIZE"
    DOCUMENT_COUNT=$(mongosh --quiet --eval "db.products.countDocuments()" 2>/dev/null || mongo --quiet --eval "db.products.count()" 2>/dev/null || echo "N/A")
    echo "   Products count: $DOCUMENT_COUNT"
else
    echo "❌ MongoDB: NOT RUNNING"
    echo "   Start with: sudo systemctl start mongod"
fi

# Check Nginx Status
echo ""
echo "🌐 Nginx Status:"
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx: RUNNING"
else
    echo "❌ Nginx: NOT RUNNING"
    echo "   Start with: sudo systemctl restart nginx"
fi

# Check Port 3000 (Node.js)
echo ""
echo "🔌 Port 3000 (Node.js):"
if sudo ss -tlnp 2>/dev/null | grep -q ":3000 " || sudo lsof -i:3000 2>/dev/null | grep -q "node"; then
    echo "✅ Port 3000: LISTENING"
elif curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Port 3000: RESPONDING"
else
    echo "❌ Port 3000: NOT LISTENING (App may not be running)"
fi

# Check Port 443 (HTTPS)
echo ""
echo "🔒 Port 443 (HTTPS):"
if sudo ss -tlnp 2>/dev/null | grep -q ":443 " || sudo lsof -i:443 2>/dev/null | grep -q "nginx"; then
    echo "✅ Port 443: LISTENING"
else
    echo "⚠️  Port 443: NOT LISTENING (SSL might not be configured)"
fi

# Check Disk Space
echo ""
echo "💾 Disk Space:"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo "   Root partition: ${DISK_USAGE}% used"
if [ "$DISK_USAGE" -gt 85 ] 2>/dev/null; then
    echo "   ⚠️  WARNING: Disk usage is high!"
fi

# Check Last Backup
echo ""
echo "📦 Last MongoDB Backup:"
LAST_BACKUP=$(ls -lt /var/backups/mongodb/backup_*.tar.gz 2>/dev/null | head -1 | awk '{print $6, $7, $8}')
if [ -n "$LAST_BACKUP" ]; then
    echo "   ✅ $LAST_BACKUP"
else
    echo "   ⚠️  No backups found"
fi

echo ""
echo "================================================="
echo "✅ Health check completed"
echo "================================================="

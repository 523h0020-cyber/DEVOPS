#!/bin/bash
# Health Check Script - Monitor application and database status

echo "================================================="
echo "🏥 HEALTH CHECK - $(date)"
echo "================================================="

# Check Node.js Application
echo ""
echo "📱 Application Status:"
if pm2 list | grep -q "midterm-app"; then
    STATUS=$(pm2 list | grep midterm-app | awk '{print $10}')
    if [ "$STATUS" = "online" ]; then
        echo "✅ App Status: ONLINE"
        pm2 list | grep midterm-app
    else
        echo "⚠️  App Status: $STATUS (Check logs: pm2 logs midterm-app)"
    fi
else
    echo "❌ App not found in PM2"
fi

# Check MongoDB Status
echo ""
echo "🗄️  MongoDB Status:"
if systemctl is-active --quiet mongod; then
    echo "✅ MongoDB: RUNNING"
    MONGO_SIZE=$(du -sh /var/lib/mongodb 2>/dev/null | awk '{print $1}')
    echo "   Data size: $MONGO_SIZE"
    DOCUMENT_COUNT=$(mongo --quiet --eval "db.products.countDocuments()" 2>/dev/null || echo "N/A")
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
if netstat -tlnp 2>/dev/null | grep -q ":3000 "; then
    echo "✅ Port 3000: LISTENING"
else
    echo "❌ Port 3000: NOT LISTENING"
fi

# Check Port 443 (HTTPS)
echo ""
echo "🔒 Port 443 (HTTPS):"
if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    echo "✅ Port 443: LISTENING"
else
    echo "⚠️  Port 443: NOT LISTENING (SSL might not be configured)"
fi

# Check Disk Space
echo ""
echo "💾 Disk Space:"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
echo "   Root partition: $DISK_USAGE used"
if [ $(echo $DISK_USAGE | grep -oE '^[0-9]+' | head -1) -gt 85 ]; then
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

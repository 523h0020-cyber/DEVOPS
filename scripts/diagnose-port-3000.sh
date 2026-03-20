#!/bin/bash
# Comprehensive Port 3000 Diagnostic & Fix
# Run this to identify and fix EADDRINUSE error

echo "================================================="
echo "🔍 PORT 3000 DIAGNOSTIC TOOL"
echo "================================================="
echo ""

# 1. Check what's using port 3000
echo "1️⃣  What's using port 3000?"
echo "---"
USING_3000=$(sudo lsof -i :3000 2>/dev/null || true)
if [ -z "$USING_3000" ]; then
    echo "   Nothing found via lsof"
else
    echo "$USING_3000"
fi
echo ""

# 2. Check netstat
echo "2️⃣  Netstat check on port 3000"
echo "---"
sudo netstat -tlnp 2>/dev/null | grep :3000 || echo "   Nothing found via netstat"
echo ""

# 3. Check all node processes
echo "3️⃣  All Node.js processes running"
echo "---"
ps aux | grep -E "node|pm2" | grep -v grep || echo "   No node/pm2 processes"
echo ""

# 4. Check PM2 status
echo "4️⃣  PM2 Status"
echo "---"
pm2 list || echo "   PM2 not initialized"
echo ""

# 5. Check if port is in TIME_WAIT
echo "5️⃣  Detailed port status (TIME_WAIT check)"
echo "---"
sudo ss -tlnp 2>/dev/null | grep :3000 || echo "   No time_wait found"
echo ""

# 6. Kill everything
echo "6️⃣  KILLING ALL NODE PROCESSES & PM2"
echo "---"
echo "   Killing PM2..."
pm2 kill || true
sleep 1

echo "   Killing all node..."
sudo pkill -9 -f node || true
sleep 1

echo "   Killing by port..."
sudo lsof -i :3000 -t | xargs -r sudo kill -9 || true
sleep 2

echo "✅ All killed"
echo ""

# 7. Verify port is free
echo "7️⃣  Verify port 3000 is FREE"
echo "---"
if sudo lsof -i :3000 >/dev/null 2>&1; then
    echo "❌ Port STILL in use!"
    sudo lsof -i :3000
    echo ""
    echo "💡 Try: sudo fuser -k 3000/tcp"
    exit 1
else
    echo "✅ Port 3000 is FREE"
fi
echo ""

# 8. Start fresh
echo "8️⃣  Starting Node.js app fresh"
echo "---"
APP_DIR="/var/www/midterm-app/src/sample-midterm-project/sample-midterm-node.js-project"

if [ ! -d "$APP_DIR" ]; then
    echo "❌ App directory not found: $APP_DIR"
    exit 1
fi

cd $APP_DIR

# Verify main.js exists
if [ ! -f "main.js" ]; then
    echo "❌ main.js not found"
    exit 1
fi

# Verify node_modules
if [ ! -d "node_modules" ]; then
    echo "⚠️  node_modules missing - installing..."
    npm install
fi

# Start with PM2
echo "   Starting: pm2 start main.js --name midterm-app"
pm2 start main.js --name midterm-app --max-memory-restart 500M
sleep 3

echo "✅ App started"
echo ""

# 9. Verify startup
echo "9️⃣  Verify port 3000 now listening"
echo "---"
if sudo lsof -i :3000 >/dev/null 2>&1; then
    echo "✅ Port 3000 NOW LISTENING"
    sudo lsof -i :3000
else
    echo "❌ Port 3000 NOT listening"
    echo "   Checking PM2 logs..."
    pm2 logs midterm-app --lines 30 --nostream
fi
echo ""

# 10. Test HTTP
echo "🔟 Test HTTP connect"
echo "---"
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ HTTP response OK"
    curl -s http://localhost:3000 | head -20
else
    echo "⚠️  HTTP connect failed (might still work through Nginx)"
fi
echo ""

# 11. Save PM2
echo "1️⃣1️⃣ Save PM2 startup"
echo "---"
pm2 save
if [ -n "$SUDO_USER" ]; then
    sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $(whoami) --hp $HOME || true
fi
echo "✅ PM2 saved"
echo ""

echo "================================================="
echo "📊 FINAL STATUS"
echo "================================================="
echo ""
echo "App Status:"
pm2 status || echo "   PM2 inactive"
echo ""
echo "Port Status:"
sudo netstat -tlnp 2>/dev/null | grep -E ":3000|:80|:443" | sed 's/^/   /' || echo "   No services on 80/443/3000"
echo ""
echo "MongoDB Status:"
sudo systemctl status mongod --no-pager 2>&1 | grep -E "Active|inactive" || echo "   Status unknown"
echo ""
echo "Nginx Status:"
sudo systemctl status nginx --no-pager 2>&1 | grep -E "Active|inactive" || echo "   Status unknown"
echo ""

echo "================================================="
echo "If port 3000 is still not working:"
echo "================================================="
echo "1. Check app logs:    pm2 logs midterm-app"
echo "2. Check errors:      pm2 errors"
echo "3. Run test:          curl -v http://localhost:3000"
echo "4. Check MongoDB:     mongo --eval 'db.adminCommand(\"ping\")'"
echo "5. Check Nginx:       sudo nginx -t"
echo ""

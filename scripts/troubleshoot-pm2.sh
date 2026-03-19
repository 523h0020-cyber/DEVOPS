#!/bin/bash
# Troubleshooting PM2 midterm-app not found

echo "🔧 TROUBLESHOOTING PM2 ERROR: Process 'midterm-app' not found"
echo "=========================================================="
echo ""

# 1. Check if app has been started
echo "1️⃣  Checking PM2 status..."
pm2 list
echo ""

# 2. Check if app directory exists
echo "2️⃣  Checking app directory..."
APP_DIR="/var/www/midterm-app/src/sample-midterm-project/sample-midterm-node.js-project"
if [ -d "$APP_DIR" ]; then
    echo "✅ App directory exists: $APP_DIR"
    ls -la $APP_DIR | head -10
else
    echo "❌ App directory NOT found at $APP_DIR"
    echo "   Need to clone repository first"
    exit 1
fi
echo ""

# 3. Check if node_modules installed
echo "3️⃣  Checking npm dependencies..."
if [ -d "$APP_DIR/node_modules" ]; then
    echo "✅ node_modules exists"
else
    echo "❌ node_modules NOT found - installing..."
    cd $APP_DIR
    npm install
    echo "✅ Dependencies installed"
fi
echo ""

# 4. Check if .env file exists
echo "4️⃣  Checking .env configuration..."
if [ -f "$APP_DIR/.env" ]; then
    echo "✅ .env file exists"
    cat $APP_DIR/.env | grep -E "NODE_ENV|PORT|MONGO_URI"
else
    echo "⚠️  .env file NOT found - creating from .env.example..."
    if [ -f "$APP_DIR/.env.example" ]; then
        cp $APP_DIR/.env.example $APP_DIR/.env
        echo "✅ Created .env from example"
    fi
fi
echo ""

# 5. Check MongoDB connection
echo "5️⃣  Checking MongoDB..."
if systemctl is-active --quiet mongod; then
    echo "✅ MongoDB is running"
    # Test connection
    mongosh --quiet --eval "db.adminCommand('ping')" 2>/dev/null && echo "✅ MongoDB connection OK" || echo "⚠️  MongoDB connection failed"
else
    echo "❌ MongoDB is NOT running"
    echo "   Starting MongoDB..."
    sudo systemctl start mongod
    sleep 2
    if systemctl is-active --quiet mongod; then
        echo "✅ MongoDB started successfully"
    fi
fi
echo ""

# 6. Start the app with PM2
echo "6️⃣  Starting app with PM2..."
cd $APP_DIR

# Kill old processes if exist
pm2 delete midterm-app || true
sleep 1

# Start with ecosystem config if available
if [ -f "/var/www/midterm-app/src/ecosystem.config.js" ]; then
    echo "Using ecosystem.config.js..."
    pm2 start /var/www/midterm-app/src/ecosystem.config.js
else
    echo "Starting directly from main.js..."
    pm2 start main.js --name "midterm-app" --env production
fi

# Save PM2 startup
pm2 save
echo "✅ App started with PM2"
echo ""

# 7. Verify app is running
echo "7️⃣  Verifying app status..."
sleep 2
pm2 status midterm-app || pm2 list

echo ""
echo "=========================================================="
echo "💡 Next steps:"
echo "   - Check app logs: pm2 logs midterm-app"
echo "   - Check port 3000: netstat -tlnp | grep 3000"
echo "   - Check Nginx: sudo systemctl status nginx"
echo "=========================================================="

#!/bin/bash
# Complete Deployment Script for AWS
# This script orchestrates all phases of deployment

set -e

DOMAIN="523h0020.site"
EMAIL="lenamgiang5@gmail.com"
PROJECT_DIR="/var/www/midterm-app"
REPO_URL="https://github.com/523h0020-cyber/DEVOPS.git"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================="
echo "🚀 AWS DEPLOYMENT ORCHESTRATOR"
echo "================================================="
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "Project: $PROJECT_DIR"
echo "================================================="

# Step 1: Phase 1 Setup
if [ ! -d "$PROJECT_DIR" ]; then
    echo ""
    echo "▶️  PHASE 1: Initial Server Setup..."
    bash $SCRIPTS_DIR/setup.sh
else
    echo "✅ Phase 1: Project directory already exists"
fi

# Step 2: Phase 2 Deployment
echo ""
echo "▶️  PHASE 2: Application & MongoDB Setup..."
bash $SCRIPTS_DIR/phase2.sh

# Step 3: Setup Backup Cron Job
echo ""
echo "▶️  Setting up MongoDB Backup Schedule..."
BACKUP_SCRIPT="/usr/local/bin/backup-mongodb.sh"
sudo cp $SCRIPTS_DIR/backup-mongodb.sh $BACKUP_SCRIPT
sudo chmod +x $BACKUP_SCRIPT

# Add daily backup at 2 AM
CRON_JOB="0 2 * * * $BACKUP_SCRIPT >> /var/log/mongodb-backup.log 2>&1"
(sudo crontab -l 2>/dev/null || echo "") | grep -v "$BACKUP_SCRIPT" | sudo crontab -
echo "$CRON_JOB" | sudo crontab -

echo "✅ MongoDB backup scheduled daily at 2 AM"

# Step 4: Copy Ecosystem Config
echo ""
echo "▶️  Deploying PM2 Ecosystem Configuration..."
cp $SCRIPTS_DIR/ecosystem.config.js $PROJECT_DIR/src/
cd $PROJECT_DIR/src/sample-midterm-project/sample-midterm-node.js-project
pm2 stop all || true
pm2 start $PROJECT_DIR/src/ecosystem.config.js
pm2 save

# Step 5: Phase 3 SSL Setup
echo ""
echo "▶️  PHASE 3: SSL & Domain Configuration..."
echo "⚠️  IMPORTANT: Ensure DNS for $DOMAIN points to this server's IP address!"
read -p "Continue with SSL setup? (yes/no) " -n 3 -r
echo
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    bash $SCRIPTS_DIR/phase3-ssl-setup.sh
else
    echo "⏭️  Skipping SSL setup. You can run it later with: bash phase3-ssl-setup.sh"
fi

echo ""
echo "================================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "================================================="
echo "📍 Access your application:"
echo "   🌐 https://$DOMAIN"
echo ""
echo "📋 Useful Commands:"
echo "   View logs:        pm2 logs midterm-app"
echo "   Status:           pm2 status"
echo "   Backup data:      bash $SCRIPTS_DIR/backup-mongodb.sh"
echo "   Restore backup:   bash $SCRIPTS_DIR/restore-mongodb.sh /path/to/backup"
echo "   Stop app:         pm2 stop midterm-app"
echo "   Restart app:      pm2 restart midterm-app"
echo ""
echo "🔒 SSL Status: https://www.ssllabs.com/ssltest/analyze.html?d=$DOMAIN"
echo "================================================="

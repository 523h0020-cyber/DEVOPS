#!/bin/bash
# MongoDB Backup Script - Run daily via cron
# Purpose: Backup MongoDB data to prevent data loss

BACKUP_DIR="/var/backups/mongodb"
BACKUP_RETENTION_DAYS=7
DATABASE_NAME="products_db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "[$(date)] Starting MongoDB backup..."

# Perform MongoDB dump
mongodump --db $DATABASE_NAME --out /tmp/mongodb_dump_$TIMESTAMP

# Compress the dump
tar -czf $BACKUP_FILE -C /tmp mongodb_dump_$TIMESTAMP

# Remove temporary dump folder
rm -rf /tmp/mongodb_dump_$TIMESTAMP

# Check if backup was successful
if [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(ls -lh "$BACKUP_FILE" | awk '{print $5}')
    echo "[$(date)] ✅ Backup successful: $BACKUP_FILE ($BACKUP_SIZE)"
    
    # Remove old backups (older than BACKUP_RETENTION_DAYS)
    find $BACKUP_DIR -type f -name "backup_*.tar.gz" -mtime +$BACKUP_RETENTION_DAYS -delete
    echo "[$(date)] Cleaned old backups (older than $BACKUP_RETENTION_DAYS days)"
else
    echo "[$(date)] ❌ Backup failed!"
    exit 1
fi

# Optional: Upload to S3 for extra safety
# aws s3 cp $BACKUP_FILE s3://your-bucket/mongodb-backups/

echo "[$(date)] Backup process completed."

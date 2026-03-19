#!/bin/bash
# MongoDB Restore Script
# Usage: ./restore-mongodb.sh /var/backups/mongodb/backup_20240319_120000.tar.gz

if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file>"
    echo "Example: $0 /var/backups/mongodb/backup_20240319_120000.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"
TEMP_DIR="/tmp/mongodb_restore_$$"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "[$(date)] Starting MongoDB restore from $BACKUP_FILE..."

# Extract backup
mkdir -p $TEMP_DIR
tar -xzf $BACKUP_FILE -C $TEMP_DIR

# Restore to MongoDB
mongorestore --drop --dir $TEMP_DIR/mongodb_dump_*

# Clean up
rm -rf $TEMP_DIR

echo "[$(date)] ✅ Restore completed successfully!"

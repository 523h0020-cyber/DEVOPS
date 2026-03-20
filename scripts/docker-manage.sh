#!/bin/bash
# Docker Compose Management Script
# Start, stop, restart, logs, backup containers

COMMAND="${1:-help}"

show_help() {
    cat <<EOF
Docker Compose Management Tool

Usage: docker-manage.sh [command] [options]

Commands:
  start          - Start all containers
  stop           - Stop all containers gracefully
  restart        - Restart all containers
  status         - Show container status
  logs [service] - View logs (web|mongodb|all)
  shell [cmd]    - Execute command in web container
  db-shell       - Open MongoDB shell
  backup         - Backup MongoDB data
  restore [file] - Restore MongoDB from backup
  cleanup        - Remove containers and volumes (careful!)
  health         - Show health status
  help           - Show this message

Examples:
  ./docker-manage.sh start
  ./docker-manage.sh logs web
  ./docker-manage.sh backup
  ./docker-manage.sh shell npm test
EOF
}

case $COMMAND in
    start)
        echo "🚀 Starting containers..."
        docker-compose up -d
        echo "✅ Containers started"
        sleep 5
        docker-compose ps
        ;;
    
    stop)
        echo "🛑 Stopping containers..."
        docker-compose stop
        echo "✅ Containers stopped"
        ;;
    
    restart)
        echo "🔄 Restarting containers..."
        docker-compose restart
        echo "✅ Containers restarted"
        sleep 5
        docker-compose ps
        ;;
    
    status)
        echo "📊 Container Status:"
        docker-compose ps
        ;;
    
    logs)
        SERVICE="${2:-web}"
        if [ "$SERVICE" = "all" ]; then
            docker-compose logs -f
        else
            docker-compose logs -f $SERVICE
        fi
        ;;
    
    shell)
        CMD="${2:-bash}"
        echo "📦 Executing in web container: $CMD"
        docker-compose exec web $CMD
        ;;
    
    db-shell)
        echo "🗄️  Opening MongoDB shell..."
        docker-compose exec mongodb mongosh
        ;;
    
    backup)
        echo "💾 Backing up MongoDB..."
        BACKUP_DIR="./backups"
        mkdir -p $BACKUP_DIR
        TIMESTAMP=$(date -u +%Y%m%d_%H%M%S)
        BACKUP_FILE="$BACKUP_DIR/mongodb_backup_$TIMESTAMP.tar.gz"
        
        docker-compose exec -T mongodb mongodump --archive=/tmp/backup.archive
        docker-compose cp mongodb:/tmp/backup.archive - | tar xz -C $BACKUP_DIR
        
        echo "✅ Backup saved: $BACKUP_FILE"
        ls -lh $BACKUP_DIR
        ;;
    
    restore)
        BACKUP_FILE="${2:-}"
        if [ -z "$BACKUP_FILE" ]; then
            echo "❌ Please specify backup file"
            ls -la ./backups/
            exit 1
        fi
        
        if [ ! -f "$BACKUP_FILE" ]; then
            echo "❌ Backup file not found: $BACKUP_FILE"
            exit 1
        fi
        
        echo "⚠️  WARNING: This will overwrite existing data!"
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📥 Restoring from $BACKUP_FILE..."
            docker-compose exec -T mongodb mongorestore --archive=/tmp/backup.archive
            echo "✅ Restore complete"
        fi
        ;;
    
    cleanup)
        echo "⚠️  WARNING: This will remove containers and volumes!"
        read -p "Delete containers? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down
            echo "✅ Containers removed"
        fi
        ;;
    
    health)
        echo "🏥 Health Check:"
        echo ""
        
        echo "MongoDB:"
        if docker-compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" >/dev/null 2>&1; then
            echo "  ✅ Healthy"
        else
            echo "  ⚠️  Unhealthy"
        fi
        
        echo "Web App:"
        if curl -s http://localhost:3000 >/dev/null 2>&1; then
            echo "  ✅ Healthy"
        else
            echo "  ⚠️  Unhealthy"
        fi
        
        echo ""
        echo "Container stats:"
        docker-compose stats --no-stream
        ;;
    
    *)
        show_help
        ;;
esac

#!/bin/bash
# Troubleshoot Docker and Docker Compose issues

COMMAND="${1:-help}"

show_help() {
    cat <<EOF
Docker Troubleshooting Tool

Usage: docker-troubleshoot.sh [command]

Commands:
  logs              - Show detailed logs from all containers
  connections       - Check container-to-container networking
  volumes           - Check volume mounts and persistence
  ports             - Verify port bindings
  resources         - Show resource usage
  networks          - List Docker networks
  images            - Show Docker images
  rebuild           - Rebuild images and containers
  reset             - Stop and remove all containers/volumes (CAREFUL!)
  help              - Show this message

Examples:
  ./docker-troubleshoot.sh logs
  ./docker-troubleshoot.sh connections
  ./docker-troubleshoot.sh rebuild
EOF
}

case $COMMAND in
    logs)
        echo "📋 Docker Compose Logs:"
        echo ""
        docker-compose logs --tail=50
        ;;
    
    connections)
        echo "🌐 Testing Container Connections:"
        echo ""
        
        echo "1. Ping MongoDB from web container:"
        docker-compose exec -T web ping -c 2 mongodb || echo "Failed (expected in some Alpine images)"
        
        echo ""
        echo "2. Connect to MongoDB from web container:"
        docker-compose exec -T web node -e "
          require('mongoose').connect('mongodb://mongodb:27017/products_db')
            .then(() => console.log('✅ Success'))
            .catch(err => console.error('❌ Error:', err.message))
        "
        
        echo ""
        echo "3. MongoDB service DNS resolution:"
        docker-compose exec -T web nslookup mongodb || echo "nslookup not available"
        
        echo ""
        echo "4. Listing network interfaces:"
        docker-compose ps
        ;;
    
    volumes)
        echo "💾 Volume Information:"
        echo ""
        
        echo "Docker volumes:"
        docker volume ls
        
        echo ""
        echo "Volume details:"
        docker volume inspect $(docker volume ls -q 2>/dev/null | head -1) 2>/dev/null || echo "No volumes found"
        
        echo ""
        echo "Host directories:"
        ls -la /var/lib/midterm-app/
        ls -la ./public/uploads/ 2>/dev/null || echo "Local uploads dir not found"
        
        echo ""
        echo "Files in MongoDB volume:"
        sudo ls -la /var/lib/midterm-app/mongodb/ | head -20
        ;;
    
    ports)
        echo "🔌 Port Bindings:"
        echo ""
        
        sudo netstat -tlnp 2>/dev/null | grep -E ':(80|443|3000|27017)' || netstat -tln | grep -E ':(80|443|3000|27017)' || lsof -i -n -P | grep LISTEN
        
        echo ""
        echo "Container port mapping:"
        docker-compose ps
        ;;
    
    resources)
        echo "📊 Resource Usage:"
        echo ""
        docker stats --no-stream
        
        echo ""
        echo "Disk usage:"
        docker system df
        ;;
    
    networks)
        echo "🌐 Docker Networks:"
        echo ""
        docker network ls
        
        echo ""
        echo "Inspecting midterm network:"
        docker network inspect midterm-network 2>/dev/null || docker network inspect midterm_midterm-network 2>/dev/null || echo "Network not found"
        ;;
    
    images)
        echo "🖼️  Docker Images:"
        echo ""
        docker images
        
        echo ""
        echo "Image size breakdown:"
        docker images --format "{{.Repository}}\t{{.Size}}"
        ;;
    
    rebuild)
        echo "🔨 Rebuilding Docker setup..."
        echo ""
        
        echo "1. Stopping containers..."
        docker-compose stop
        
        echo "2. Removing containers..."
        docker-compose rm -f
        
        echo "3. Pulling latest images..."
        docker-compose pull
        
        echo "4. Starting containers..."
        docker-compose up -d
        
        echo "5. Waiting for health checks..."
        sleep 15
        
        echo ""
        echo "Status:"
        docker-compose ps
        ;;
    
    reset)
        echo "⚠️  WARNING: This will remove all containers and volumes!"
        read -p "Continue? Type 'yes' to confirm: " -r
        echo
        if [[ $REPLY == "yes" ]]; then
            echo "Removing all Docker resources..."
            docker-compose down -v
            echo "✅ Done"
        else
            echo "Cancelled"
        fi
        ;;
    
    *)
        show_help
        ;;
esac

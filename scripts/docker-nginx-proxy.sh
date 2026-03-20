#!/bin/bash
# Update Nginx to proxy requests to Docker container

set -e

echo "=================================================="
echo "🌐 NGINX → DOCKER PROXY CONFIG"
echo "=================================================="
echo ""

NGINX_CONF="/etc/nginx/sites-available/midterm-app"
DOMAIN="523h0020.site"

echo "Creating Nginx configuration..."
echo "Domain: $DOMAIN"
echo ""

# Create Nginx config that proxies to Docker container
sudo tee $NGINX_CONF > /dev/null <<'EOF'
# Nginx Reverse Proxy for Docker Container

# HTTP -> HTTPS redirect
server {
    listen 80;
    server_name 523h0020.site www.523h0020.site;
    
    location / {
        return 301 https://$server_name$request_uri;
    }
    
    # Let's Encrypt ACME challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}

# HTTPS with Docker proxy
server {
    listen 443 ssl http2;
    server_name 523h0020.site www.523h0020.site;
    
    # SSL Certificates (from Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/523h0020.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/523h0020.site/privkey.pem;
    
    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy to Docker container (service name: "web" resolves to 172.x.x.x)
    location / {
        # Docker container is accessible on localhost:3000
        proxy_pass http://localhost:3000;
        
        # Preserve headers
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # No caching for dynamic content
        proxy_cache_bypass $http_upgrade;
    }
    
    # Proxy uploads to Docker container
    location /uploads/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        client_max_body_size 100M;  # Allow large file uploads
    }
}
EOF

echo "✅ Nginx configuration created"
echo ""

# Check symlink
if [ -L "/etc/nginx/sites-enabled/midterm-app" ]; then
    echo "✅ Symlink already exists"
else
    echo "Creating symlink..."
    sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
    echo "✅ Symlink created"
fi
echo ""

# Test Nginx config
echo "Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi
echo ""

# Remove default config
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    echo "Removing default Nginx config..."
    sudo rm -f /etc/nginx/sites-enabled/default
    echo "✅ Default config removed"
fi
echo ""

# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx
echo "✅ Nginx restarted"
echo ""

echo "=================================================="
echo "✅ NGINX CONFIGURATION COMPLETE!"
echo "=================================================="
echo ""
echo "Proxy setup:"
echo "  TCP 80   → HTTPS redirect"
echo "  TCP 443  → http://localhost:3000 (Docker container)"
echo ""
echo "Test with:"
echo "  curl https://523h0020.site"
echo "  curl -k https://localhost"
echo ""

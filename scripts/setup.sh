#!/bin/bash

# setup.sh - Environment setup script for Midterm Project
# Automates the installation of Node.js, PM2, Nginx, and sets up required directories.
# Run this script with root privileges (sudo).

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting server setup..."

# 1. Update and upgrade system packages
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# 2. Install essential tools
echo "Installing essential tools (curl, git, ufw)..."
apt-get install -y curl git ufw

# 3. Install Node.js (LTS version - v20)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
echo "Node $(node -v) and NPM $(npm -v) installed."

# 4. Install PM2 globally
echo "Installing PM2..."
npm install pm2@latest -g
pm2 update

# 5. Install Nginx
echo "Installing Nginx..."
apt-get install -y nginx

# Setup basic Nginx firewall rules if UFW is active
echo "Configuring firewall..."
ufw allow 'Nginx Full' || true

# 6. Set up project directories
PROJECT_DIR="/var/www/midterm-app"
echo "Creating required directories at $PROJECT_DIR..."

mkdir -p $PROJECT_DIR/src
mkdir -p $PROJECT_DIR/docs
mkdir -p $PROJECT_DIR/scripts

# Change ownership of the project directory to the current user (the non-root user running the app)
# Assuming the user is running the script as sudo, $SUDO_USER holds the original user
APP_USER=${SUDO_USER:-$USER}
chown -R $APP_USER:$APP_USER $PROJECT_DIR

echo "Setup completed successfully!"
echo "You can now clone your repository into $PROJECT_DIR/src and start the application."

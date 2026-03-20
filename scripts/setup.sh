#!/bin/bash

# setup.sh - Environment setup script for Midterm Project
# Automates the installation of Node.js, Python 3, PM2, Nginx, and sets up required directories.
# Run this script with root privileges (sudo).

# You can update this REPO_URL with your actual repository link
REPO_URL=""

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting server setup for Ubuntu 24.04 LTS..."

# 1. Update and upgrade system packages
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# 2. Install essential tools & Python (Ubuntu 24.04 requires venv for pip)
echo "Installing essential tools (curl, git, ufw) and Python 3..."
apt-get install -y curl git ufw python3 python3-pip python3-venv

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
ufw allow 22/tcp
ufw allow 'Nginx Full' || true

# 6. Set up project directories
PROJECT_DIR="/var/www/midterm-app"
echo "Creating required directories at $PROJECT_DIR..."

mkdir -p $PROJECT_DIR/src
mkdir -p $PROJECT_DIR/docs
mkdir -p $PROJECT_DIR/scripts

# 7. Clone Repository
if [ -n "$REPO_URL" ]; then
    echo "Cloning repository from $REPO_URL..."
    # If the src directory already has contents, you might need to handle it or git clone might fail
    # So we remove it and re-clone
    rm -rf $PROJECT_DIR/src
    git clone $REPO_URL $PROJECT_DIR/src
else
    echo "No REPO_URL specified. Skipping git clone."
fi

# Change ownership of the project directory to the current user (the non-root user running the app)
# Assuming the user is running the script as sudo, $SUDO_USER holds the original user
APP_USER=${SUDO_USER:-$USER}
chown -R $APP_USER:$APP_USER $PROJECT_DIR

echo "Setup completed successfully!"
if [ -z "$REPO_URL" ]; then
    echo "You can now clone your repository into $PROJECT_DIR/src and start the application."
else
    echo "Your repository is cloned at $PROJECT_DIR/src."
fi

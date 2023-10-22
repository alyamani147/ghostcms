#!/bin/bash

# Update package list
sudo apt-get update

# Install Node.js
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Nginx (optional, for serving Ghost)
sudo apt-get install -y nginx

# Install Ghost CLI
sudo npm install -g ghost-cli

# Create a directory for Ghost
sudo mkdir -p /var/www/ghost
sudo chown ubuntu:ubuntu /var/www/ghost
cd /var/www/ghost

# Install Ghost in the directory
ghost install

# Configure Nginx (optional)
sudo cp /var/www/ghost/system/files/ghost.service /etc/systemd/system/ghost_your-blog-name.service
sudo systemctl start ghost_your-blog-name
sudo systemctl enable ghost_your-blog-name

# Output the URL of your Ghost instance
echo "Your Ghost CMS is now accessible at: http://your-ec2-instance-ip"

# Additional configurations can be added based on your requirements

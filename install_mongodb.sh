#!/bin/bash

echo "Start installing MongoDB"

# Check if MongoDB is already installed
if dpkg-query -W -f='${Status}' mongodb-org 2>/dev/null | grep -q "ok installed"; then
    echo "MongoDB is already installed. Skipping installation..."
    exit 0
fi

# Update the package manager
echo "Updating package manager..."
sudo apt-get update -y

# Install necessary dependencies
echo "Installing necessary dependencies..."
sudo apt-get install -y gnupg

# Add MongoDB's official GPG key
echo "Adding MongoDB's official GPG key..."
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

# Add MongoDB's official repository
echo "Adding MongoDB's official repository..."
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# Update the package manager again to include MongoDB's repository
echo "Updating package manager with MongoDB's repository..."
sudo apt-get update -y

# Install MongoDB
echo "Installing MongoDB..."
sudo apt-get install -y mongodb-org

# Create the data directory for MongoDB
echo "Creating data directory for MongoDB..."
sudo mkdir -p /data/db

# Change ownership of the data directory to the MongoDB user
echo "Changing ownership of the data directory..."
sudo chown -R mongodb:mongodb /data/db

# Start MongoDB service
echo "Starting MongoDB service..."
sudo systemctl start mongod

# Enable MongoDB service to start on boot
echo "Enabling MongoDB service to start on boot..."
sudo systemctl enable mongod

# Verify the MongoDB service status
echo "Checking MongoDB service status..."
sudo systemctl status mongod

echo "End of MongoDB installation"

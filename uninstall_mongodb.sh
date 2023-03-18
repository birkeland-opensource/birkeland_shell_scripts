#!/bin/bash

echo "Uninstalling MongoDB"

# Stop the MongoDB service
echo "Stopping MongoDB service..."
sudo systemctl stop mongod

# Disable the MongoDB service
echo "Disabling MongoDB service..."
sudo systemctl disable mongod

# Remove the MongoDB packages
echo "Removing MongoDB packages..."
sudo apt-get purge -y mongodb-org*


# Remove the MongoDB data directory
echo "Removing MongoDB data directory..."
sudo rm -r /data/db

# Remove the MongoDB log directory (if it exists)
echo "Removing MongoDB log directory..."
sudo rm -r /var/log/mongodb

# Remove the MongoDB configuration file (if it exists)
echo "Removing MongoDB configuration file..."
sudo rm /etc/mongod.conf

# Remove the MongoDB repository information
echo "Removing MongoDB repository information..."
sudo rm /etc/apt/sources.list.d/mongodb-org-5.0.list

# Remove the MongoDB GPG key
echo "Removing MongoDB GPG key..."
sudo apt-key del "$(sudo apt-key list | grep -B 1 "MongoDB" | head -n 1 | awk -F/ '{print $2}' | awk '{print $1}')"

# Update the package manager
echo "Updating package manager..."
sudo apt-get update

echo "MongoDB uninstalled successfully"

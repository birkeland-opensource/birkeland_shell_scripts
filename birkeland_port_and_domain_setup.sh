#!/bin/bash

# Take the domain name as an argument
domain=$1

# Check if domain name is provided
if [ -z "$domain" ]; then
  echo "Please provide a domain name as an argument."
  exit 1
fi

# Install Nginx
sudo apt-get update
sudo apt-get install -y nginx

# Create sites-available and sites-enabled directories
sudo mkdir /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled

# Create a new Nginx server block
cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:9990;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Link the server block to the sites-enabled directory
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Restart Nginx to apply changes
sudo service nginx restart

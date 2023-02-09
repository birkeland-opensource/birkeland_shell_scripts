#!/bin/bash

# Check if required parameters are present
if [ "$#" -ne 2 ]; then
  echo "Error: Two arguments required - domain name and email address."
  exit 1
fi

domain_name=$1
email_address=$2

# Check if Nginx is installed
if ! [ -x "$(command -v nginx)" ]; then
  echo "Error: Nginx is not installed. Please install Nginx and run the script again."
  exit 1
fi

# Check if UFW firewall is installed
if ! [ -x "$(command -v ufw)" ]; then
  echo "Error: UFW firewall is not installed. Please install UFW firewall and run the script again."
  exit 1
fi

# Create a new Nginx server block
cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80;
    server_name $domain_name;

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

# Restart Nginx to apply changes
sudo service nginx restart

# Install Certbot and the Certbot Nginx plugin
sudo apt -y install certbot python3-certbot-nginx

# Check the status of UFW firewall and allow incoming traffic for Nginx Full
sudo ufw status
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
sudo ufw status

# Obtain SSL certificate using Certbot and the Nginx plugin
sudo certbot --nginx -n --agree-tos --redirect -d $domain_name -m $email_address

# Restart Nginx to apply SSL certificate
sudo service nginx restart

echo "HTTPS has been successfully enabled for $domain_name"

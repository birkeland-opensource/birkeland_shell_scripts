#!/bin/bash

# Create a new Nginx server block
cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80;
    server_name $1;

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


sudo apt -y install certbot python3-certbot-nginx

# Step 3
sudo ufw status
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
sudo ufw status

sudo certbot --nginx -n   --agree-tos  --redirect  -d $1 -d www.$1 -m $2

sudo service nginx restart
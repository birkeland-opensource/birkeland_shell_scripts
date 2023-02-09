#!/bin/bash

# Step 1: Install certbot
sudo apt-get update
sudo apt-get install certbot nginx -y

# Step 2: Obtain the SSL certificate
sudo certbot certonly --standalone -d <your_domain_name>

# Step 3: Copy the SSL certificate to the virtual machine
sudo scp /etc/letsencrypt/live/<your_domain_name>/fullchain.pem <username>@<virtual_machine_ip>:~/fullchain.pem
sudo scp /etc/letsencrypt/live/<your_domain_name>/privkey.pem <username>@<virtual_machine_ip>:~/privkey.pem

# Step 4: Install the SSL certificate on the virtual machine
ssh <username>@<virtual_machine_ip> << EOF
sudo cp ~/fullchain.pem /etc/ssl/certs/fullchain.pem
sudo cp ~/privkey.pem /etc/ssl/private/privkey.pem

# Step 5: Configure Nginx to use the SSL certificate
sudo bash -c "cat << EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name <your_domain_name>;
    return 302 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name <your_domain_name>;

    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/privkey.pem;

    location / {
        proxy_pass http://<your_app_server_ip>:<your_app_server_port>;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF"

# Step 6: Restart Nginx to apply the changes
sudo service nginx restart
EOF

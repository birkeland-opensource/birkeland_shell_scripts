#Install nginx
echo "Installing nginx..."
apt update && apt install nginx -y
if [ $? -eq 0 ]
then
  ufw allow 'Nginx HTTP'
  echo "Done Installing nginx..."
else
  echo "Error installing nginx"
  exit 1
fi


# Create a new Nginx server block
echo "start port forwarding 80 to 9990"
cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80;

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

echo "end of port forwarding 80 to 9990"

echo "Installing nodejs..."
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
if [ $? -eq 0 ]
then
  bash nodesource_setup.sh
  apt install nodejs -y
  apt install build-essential -y

  # Add make to PATH
  echo 'export PATH="$PATH:/usr/bin"' >> ~/.bashrc
  source ~/.bashrc

  if which make &> /dev/null; then
    echo "Make is installed"
  else
    echo "Error installing Make"
    exit 1
  fi

  echo "Done Installing nodejs..."
else
  echo "Error downloading nodejs setup script"
  exit 1
fi


echo "Installing PM2...."

npm install pm2@latest -g -y
if [ $? -eq 0 ]
then
  pm2 startup systemd
  env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u "$(whoami)" --hp "/home/$(whoami)"
  pm2 save
  echo "Done Installing PM2...."
else
  echo "Error installing PM2"
  exit 1
fi

ufw allow 9990/tcp
ufw enable
ufw reload

echo "Done installing"

exit
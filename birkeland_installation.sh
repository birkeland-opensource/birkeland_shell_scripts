#!/bin/bash 

echo "Installing Birkeland Stack..." 

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd ~ || exit

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

echo "Installing birkleand backend app"
mkdir -p birkeland 
cd birkeland || exit

git clone https://github.com/rubansundararaj/birkeland_lnd_grpc
if [ $? -eq 0 ]
then
  cd birkeland_lnd_grpc && npm i
  if [ $? -eq 0 ]
  then
    pm2 start /root/birkeland/birkeland_lnd_grpc/index.js
    if [ $? -eq 0 ]
    then
      echo "Done Installing birkleand backend app"
    else
      echo "Error starting birkleand backend app"
      exit 1
    fi
  else
    echo "Error installing birkleand backend app dependencies"
    exit 1
  fi
else
  echo "Error cloning birkleand backend app repository"
  exit 1
fi

cd ~ || exit

echo "Installing Golang..."

wget https://dl.google.com/go/go1.19.linux-amd64.tar.gz
if [ $? -eq 0 ]; then
  tar -xvf go1.19.linux-amd64.tar.gz
  pwd
  rm -rf /usr/local/go
  sudo mv go /usr/local
else
  echo "Error downloading Go binary"
  exit 1
fi

echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc

source ~/.bashrc
go version
echo "Go installed successfully"

ufw allow 22
ufw allow 9990
ufw enable
ufw reload

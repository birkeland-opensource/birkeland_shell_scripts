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

# Install Tor
sudo apt-get update
sudo apt-get install -y tor

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

git clone https://github.com/birkeland-opensource/birkeland_lnd_backend
if [ $? -eq 0 ]
then
  cd birkeland_lnd_backend && npm i
  if [ $? -eq 0 ]
  then
    pm2 start /root/birkeland/birkeland_lnd_backend/index.js
    if [ $? -eq 0 ]
    then
      echo "Done Installing birkleand backend app"
    else
      echo "Error starting birkleand backend app"
    
    fi
  else
    echo "Error installing birkleand backend app dependencies"
    
  fi
else
  echo "Error cloning birkleand backend app repository"
 
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

cd ~
source ~/.bashrc
go version
echo "Go installed successfully"


echo "starting to install bitcoin"
pwd 
apt-get update 
apt-get install git 
rm -rf ~/code/
mkdir -p ~/code && cd ~/code 
cd ~/code && git clone https://github.com/bitcoin/bitcoin.git 
cd ~/code/bitcoin && git checkout 23.x 
apt-get install build-essential libtool autotools-dev automake -y pkg-config bsdmainutils python3 libevent-dev 
apt-get install libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev -y 
apt-get install libsqlite3-dev -y 
apt-get install libminiupnpc-dev -y 
apt-get install libzmq3-dev -y 
apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools -y 
apt-get install libqrencode-dev -y 
cd ~/code/bitcoin && ./contrib/install_db4.sh `pwd` 
cd ~/code/bitcoin && ./autogen.sh 
export BDB_PREFIX='/root/code/bitcoin/db4' 
cd ~/code/bitcoin && ./configure BDB_LIBS="-L\${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I\${BDB_PREFIX}/include" 
cd ~/code/bitcoin && make 
sudo make install 
echo "ending bitcoin installation"

echo "starting to install lnd"
mkdir -p ~/birkeland/code
cd ~/birkeland/code && rm -rf lnd_code
mkdir -p lnd_code && cd lnd_code
git clone https://github.com/lightningnetwork/lnd
cd lnd && git checkout v0.16.0-beta
make install

echo "ending lnd installation"

echo "Start Creating Bitcoin config"
# Check if the .bitcoin folder exists, create it if not
if [ ! -d "$HOME/.bitcoin" ]; then
  mkdir "$HOME/.bitcoin"
fi

# Go to the .bitcoin folder
cd "$HOME/.bitcoin"

# Create the bitcoin.conf file if it doesn't exist, or append to it if it does
{
  echo "assumevalid=0"
  echo "txindex=1"
  echo "debug=net"
  echo "# Allows LND to connect to the Bitcoin node via an RPC user & pass"
  echo "rpcuser=birkeland"
  echo "rpcpassword=birkeland"
  echo "# Allows LND & Bitcoin Core to communicate via ZeroMQ"
  echo "zmqpubrawblock=tcp://127.0.0.1:28332"
  echo "zmqpubrawtx=tcp://127.0.0.1:28333"
} >> bitcoin.conf

echo "End Creating Bitcoin config"

echo "Start creating LND config"
# Check if the .lnd folder exists
if [ ! -d "/root/.lnd" ]; then
  # If it doesn't exist, create it
  mkdir /root/.lnd
fi

# Create the lnd.conf file
cat > /root/.lnd/lnd.conf << EOL
## LND Settings
# Lets LND know to run on top of Bitcoin (as opposed to Litecoin)
bitcoin.active=true
bitcoin.mainnet=true
# Lets LND know you are running Bitcoin Core (not btcd or Neutrino)
bitcoin.node=bitcoind
## Bitcoind Settings
# Tells LND what User/Pass to use to RPC to the Bitcoin node
bitcoind.rpcuser=birkeland
bitcoind.rpcpass=birkeland
# Allows LND & Bitcoin Core to communicate via ZeroMQ
bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332
bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333
## Zap Settings
# Tells LND to listen on all of your computer's interfaces
# This could alternatively be set to your router's subnet IP
tlsextraip=0.0.0.0
# Tells LND where to listen for RPC messages
# This could also be set to your router's subnet IP
rpclisten=0.0.0.0:10009
#Specify the interfaces to listen on for p2p connections. One listen
#address per line.
# All ipv4 on port 9735:
listen=0.0.0.0:9735
listen=[::1]:9736

tor.active=0
tor.v3=0
tor.streamisolation=0
tor.control=9051
tor.socks=9050

wtclient.active=true

EOL

# Give the user confirmation that the script has finished running
echo "The .lnd folder and lnd.conf file have been created."

echo "End creating LND config"


echo "Start installing mongodb"

# Update the package manager
sudo apt-get update

# Install MongoDB
sudo apt-get install -y mongodb

# Create the data directory for MongoDB
sudo mkdir -p /data/db

# Change ownership of the data directory to the MongoDB user
sudo chown -R mongodb:mongodb /data/db

# Start MongoDB service
sudo service mongodb start

# Verify the MongoDB service status
sudo service mongodb status


echo "End Start installing mongodb"

bitcoind --daemon 

ufw allow 9911 comment "watchtower”
ufw allow 22
ufw allow 9990/tcp
sudo ufw allow 9735/tcp
sudo ufw allow 9736/tcp
ufw enable
ufw reload

exit

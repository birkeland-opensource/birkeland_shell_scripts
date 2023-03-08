echo "starting to install lnd"
mkdir -p ~/birkeland/code
cd ~/birkeland/code && rm -rf lnd_code
mkdir -p lnd_code && cd lnd_code
git clone https://github.com/lightningnetwork/lnd
cd lnd && git checkout tags/v0.15.5-beta -b tags/v0.15.5-beta
make install

echo "ending lnd installation"
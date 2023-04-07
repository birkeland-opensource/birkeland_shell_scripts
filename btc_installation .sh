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
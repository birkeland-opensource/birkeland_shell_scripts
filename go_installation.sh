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

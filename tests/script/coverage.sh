#!/bin/bash

set -ue

sudo apt update
sudo apt-get install binutils-dev libiberty-dev libcurl4-openssl-dev libelf-dev libdw-dev cmake gcc g++

curl -sSL https://github.com/SimonKagstrom/kcov/archive/refs/tags/38.tar.gz | tar xz
mkdir kcov-38/build
pushd kcov-38/build
cmake ..
sudo make install
popd

pushd ./tests/certmock/
docker build -t letsfiware/certmock:0.2.0 .
popd

sed -i -e "s/^\(COMET=\).*/\1comet/" config.sh
sed -i -e "s/^\(QUANTUMLEAP=\).*/\1quantumleap/" config.sh
sed -i -e "s/^\(WIRECLOUD=\).*/\1wirecloud/" config.sh
sed -i -e "s/^\(NGSIPROXY=\).*/\1ngsiproxy/" config.sh
sed -i -e "s/^\(NODE_RED=\).*/\1node-red/" config.sh
sed -i -e "s/^\(GRAFANA=\).*/\1grafana/" config.sh
sed -i -e "s/^\(IMAGE_CERTBOT=\).*/\1letsfiware\/certmock:0.2.0/" config.sh
sed -i -e "s/^\(CERT_REVOKE=\).*/\1true/" config.sh

for name in coverage coverage1 coverage2 coverage3
do
  if [ -d "${name}" ]; then
    rm -fr "${name}"
  fi
  mkdir "${name}"
done

sudo rm -f /usr/local/bin/docker-compose
curl -OL https://github.com/lets-fiware/ngsi-go/releases/download/v0.8.0/ngsi-v0.8.0-linux-amd64.tar.gz
sudo tar zxvf ngsi-v0.8.0-linux-amd64.tar.gz -C /usr/local/bin
rm -f ngsi-v0.8.0-linux-amd64.tar.gz

export FIBB_TEST=true
kcov --exclude-path=tests,.git,setup,coverage ./coverage1/ ./lets-fiware.sh example.com

sleep 5

kcov --exclude-path=tests,.git,setup,coverage ./coverage2/ ./lets-fiware.sh example.com

make clean

while [ "1" != $(docker ps | wc -l) ]
do
  sleep 1
done

git checkout config.sh

IP=($(hostname -I))

kcov --exclude-path=tests,.git,setup,coverage ./coverage3/ ./lets-fiware.sh example.com "${IP[0]}"

kcov --merge ./coverage ./coverage1 ./coverage2 ./coverage3

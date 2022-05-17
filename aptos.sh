#!/usr/bin/env bash

set -x

full_node=$1
nodename=$2

if [ ! -n "$full_node" ]; then 
echo "Please set your full node ip:port" 
exit 2
fi 

if [ ! -n "$nodename" ]; then 
echo "Node Name is set as default value: myaptos" 
nodename="myaptos"
fi 


cd ~
sudo apt update
sudo apt upgrade -y

echo "Set up firewall"
ufw default deny
ufw allow ssh
ufw allow 6180/tcp
ufw allow 9101/tcp
ufw enable
ufw status


echo "Download and install aptos cli"
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip
sudo apt install unzip -y
unzip aptos-cli-0.1.1-Ubuntu-x86_64.zip
chomd +x aptos
mv aptos /usr/bin
rm -rf aptos-cli-0.1.1-Ubuntu-x86_64.zip

echo "Check if the binary works"
aptos help

echo "Install Docker"
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
docker ps

echo "Aptos Docker Installation and Configuration"
export WORKSPACE=testnet
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml
aptos genesis generate-keys --output-dir ~/$WORKSPACE
validator_port=“:6180”
validator_ip=$(curl ifconfig.me)${validator_port}
aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username ${nodename} \
    --validator-host $(curl ifconfig.me):6180 \
    --full-node-host ${full_node}
echo "---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
  - ${nodename}
chain_id: 23" > layout.yaml
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip framework.zip
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE
docker compose up -d
cat ${nodename}".yaml"

set +x

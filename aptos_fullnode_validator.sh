#!/usr/bin/env bash

set -x

nodename=$1

if [ ! -n "$nodename" ]; then 
echo "Node Name is set as default value: myaptos" 
nodename="myaptos"
fi 

echo "Set up firewall"
ufw default deny
ufw allow 22,6180,6182,9101,9102,8080,8081/tcp
ufw enable
ufw status

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


echo "Install Full Node..."
mkdir ~/aptos_full_node
mv ./docker-compose.yaml ./public_full_node.yaml ~/aptos_full_node
cd ~/aptos_full_node
wget https://devnet.aptoslabs.com/genesis.blob
wget https://devnet.aptoslabs.com/waypoint.txt

echo "Install Validator..."
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v0.1.1/aptos-cli-0.1.1-Ubuntu-x86_64.zip
sudo apt install unzip -y
unzip aptos-cli-0.1.1-Ubuntu-x86_64.zip
chomd +x aptos
mv aptos /usr/bin
rm -rf aptos-cli-0.1.1-Ubuntu-x86_64.zip
aptos help

export WORKSPACE=aptos_validator
mkdir ~/$WORKSPACE
cd ~/$WORKSPACE
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/docker-compose.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/validator.yaml
wget https://raw.githubusercontent.com/aptos-labs/aptos-core/main/docker/compose/aptos-node/fullnode.yaml
aptos genesis generate-keys --output-dir ~/$WORKSPACE
aptos genesis set-validator-configuration \
    --keys-dir ~/$WORKSPACE --local-repository-dir ~/$WORKSPACE \
    --username ${nodename} \
    --validator-host $(curl ifconfig.me):6180 \
    --full-node-host $(curl ifconfig.me):6182

echo "---
root_key: "0x5243ca72b0766d9e9cbf2debf6153443b01a1e0e6d086c7ea206eaf6f8043956"
users:
  - ${nodename}
chain_id: 23" > layout.yaml
wget https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
unzip framework.zip
aptos genesis generate-genesis --local-repository-dir ~/$WORKSPACE --output-dir ~/$WORKSPACE

sudo docker run --rm aptoslab/tools:devnet sh -c "echo '开始生成私钥...' && aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file /root/private-key.txt && echo '\n\n开始生成公钥和 Peer ID...' && aptos-operational-tool extract-peer-from-file --encoding hex --key-file /root/private-key.txt --output-file /root/peer-info.yaml && echo '\n\n你的私钥' && cat /root/private-key.txt && echo '\n\n您的公钥和 Peer ID 信息如下：' && cat /root/peer-info.yaml"

echo "Keep those information"
echo "fill in the public_full_node.yaml with your private key and peer id"






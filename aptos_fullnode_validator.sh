#!/usr/bin/env bash

set -x

echo "Set up firewall"
ufw default deny
ufw allow ssh
ufw allow 6180/tcp
ufw allow 6182/tcp
ufw allow 9101/tcp
ufw allow 8080/tcp
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
mkdir ~/aptos_full_node ~/aptos_validator
mv ./docker-compose.yaml ./public_full_node.yaml ~/aptos_full_node
cd ~/aptos_full_node
wget https://devnet.aptoslabs.com/genesis.blob
wget https://devnet.aptoslabs.com/waypoint.txt
sudo docker run --rm aptoslab/tools:devnet sh -c "echo '开始生成私钥...' && aptos-operational-tool generate-key --encoding hex --key-type x25519 --key-file /root/private-key.txt && echo '\n\n开始生成公钥和 Peer ID...' && aptos-operational-tool extract-peer-from-file --encoding hex --key-file /root/private-key.txt --output-file /root/peer-info.yaml && echo '\n\n你的私钥' && cat /root/private-key.txt && echo '\n\n您的公钥和 Peer ID 信息如下：' && cat /root/peer-info.yaml"

echo "Keep those information"
echo "fill in the public_full_node.yaml with your private key and peer id"
echo "docker compose up -d"



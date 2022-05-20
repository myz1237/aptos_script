#!/usr/bin/env bash

set -x

cd ~/aptos_full_node
docker compose down
docker volume rm aptos_full_node_db
wget -O ./waypoint.txt https://devnet.aptoslabs.com/waypoint.txt
wget -O ./genesis.blob https://devnet.aptoslabs.com/genesis.blob
docker pull docker.io/aptoslab/validator:devnet
docker compose up -d

set +x
## File Description

`aptos_fullnode_validator.sh` -- All-in-one aptos script, helping you install a fullnode and a validator in the same machine.

`aptos_validator.sh` -- Install a validator in your machine

## Usage

aptos_fullnode_validator.sh :

```
git clone https://github.com/myz1237/aptos_script.git && cd aptos_script && bash aptos_fullnode_validator.sh
```

1. After executing this script, you would have `aptos_validator` and `aptos_full_node`, two directories. Enter `aptos_full_node`, edit public_full_node.yaml, and fill in your `key` and `peer_id`

2. Copy your private key and peer ID from another file, `full_node_private_key_peer_id.txt`. Note that your peer id does not start with `0x`

3. Launch your aptos full node in the `aptos_full_node` dir.

   ```
   docker compose up -d
   ```

4. Change your directory to the folder `aptos_validator`. Open `docker-compose.yaml` and modify ports forward to prevet conflicts with your full node.

   ```yaml
       ports:
         - "6180:6180"
         - "6181:6181"
         - "8081:8080"
         - "9102:9101"
       expose:
         - 6180
         - 6181
         - 9101	
   ```

5. Launch your validator in the `aptos_validator` dir.

   ```
   docker compose up -d
   ```

6. Open the file `myaptos.yaml` and complete the [registry](https://community.aptoslabs.com/it1)

aptos_validator.sh

```
git clone https://github.com/myz1237/aptos_script.git && cd aptos_script && bash aptos_validator.sh <your full node ip:port> <validator name (defualt value: myaptos)>
```


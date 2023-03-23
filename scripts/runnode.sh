#!/bin/bash
cardano-node run \
  --config /root/cardano/config.json \
  --database-path /root/cardano/db/ \
  --socket-path /root/cardano/node.socket \
  --port 1856 \
  --topology ./env/topology.json

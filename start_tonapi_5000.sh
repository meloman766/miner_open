#!/bin/bash
npm install


while true; do
  node send_universal.js --api tonapi --bin ./pow-miner-cuda --givers 5000
  sleep 1;
done;

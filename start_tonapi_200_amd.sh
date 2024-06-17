#!/bin/bash
npm install


while true; do
  node send_universal.js --api tonapi --bin ./pow-miner-opencl --givers 200
  sleep 1;
done;

#!/bin/bash
npm install


while true; do
  node send_universal.js --api tonapi --bin ./pow-miner-opencl-macos --givers 5000
  sleep 1;
done;

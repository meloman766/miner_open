#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# install dependencies
apt install openssl -y
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb || echo "Can't install libssl1.1"
rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/main/n/nano/nano_4.8-1ubuntu1_amd64.deb
dpkg -i nano_4.8-1ubuntu1_amd64.deb || echo "Can't install nano"
rm nano_4.8-1ubuntu1_amd64.deb


# Check if miner is installed
if [ ! -d "$HOME/miner" ]; then
    echo "Miner not installed. Installing."
    
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
    
    cd "$HOME" || exit
    git clone https://github.com/TrueCarry/JettonGramGpuMiner.git miner
    
    cd miner || exit
    echo "Installing miner..."
else
    cd "$HOME/miner" || exit
    echo "Miner installed. Updating."
    git pull
    echo "Updating miner..."
fi

GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l) > /dev/null 2>&1

if [ "$GPU_COUNT" = "0" ]; then
    echo "Cant get GPU count. Aborting."
    exit 1
fi

# Create test file
cat > test.sh << EOL
#!/bin/bash

"$HOME"/miner/pow-miner-cuda -g 0 -F 128 -t 5 kQBWkNKqzCAwA9vjMwRmg7aY75Rf8lByPA9zKXoqGkHi8SM7 229760179690128740373110445116482216837 53919893334301279589334030174039261347274288845081144962207220498400000000000 10000000000 kQBWkNKqzCAwA9vjMwRmg7aY75Rf8lByPA9zKXoqGkHi8SM7 mined.boc
EOL

# Update gram start file
if [ "$GPU_COUNT" = "1" ]; then
    echo "One GPU detected. Creating start file"
    cat > gram.sh << EOL
#!/bin/bash
npm install

while true; do
    node send_universal.js --api tonapi --bin ./pow-miner-cuda --givers 1000 --timeout 4
done;
EOL
else
    echo "Detected ${GPU_COUNT} GPUs. Creating start file"
    cat > gram.sh << EOL
#!/bin/bash
npm install

while true; do
    node send_multigpu.js --api tonapi --bin ./pow-miner-cuda --givers 1000 --gpu-count ${GPU_COUNT} --timeout 4
done;
EOL
fi

# Update mrdn start file
wget https://gist.githubusercontent.com/KurimuzonAkuma/e67abd30ac893ad3cd43941d73614770/raw/f7f2ad1e640747eaca7861d03f42569b9ef4fb84/send_multigpu_meridian.js
if [ "$GPU_COUNT" = "1" ]; then
    echo "One GPU detected. Creating start file"
    cat > mrdn.sh << EOL
#!/bin/bash
npm install

while true; do
    node send_meridian.js --api tonapi --bin ./pow-miner-cuda --givers 1000 --timeout 4
done;
EOL
else
    echo "Detected ${GPU_COUNT} GPUs. Creating start file"
    cat > mrdn.sh << EOL
#!/bin/bash
npm install

while true; do
    node send_multigpu_meridian.js --api tonapi --bin ./pow-miner-cuda --givers 1000 --gpu-count ${GPU_COUNT} --timeout 4
done;
EOL
fi

chmod +x test.sh
chmod +x gram.sh
chmod +x mrdn.sh

if [ ! -f config.txt ]; then
    cat > config.txt << EOL
SEED=
TONAPI_TOKEN=
TARGET_ADDRESS=
EOL
fi

echo -e "Start mining with ${GREEN}./gram.sh${NC} or ${GREEN}./mrdn.sh${NC}"
echo -e "${RED}DONT FORGET TO CREATE config.txt BEFORE START!!!${NC}"

#!/bin/bash

# Text colors
RED='\033[0;31m'
NC='\033[0m' # No Color (reset)

# Check for curl and install if not present
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

# Display logo
curl -s https://raw.githubusercontent.com/Evenorchik/evenorlogo/refs/heads/main/evenorlogo.sh | bash

# Menu
echo -e "${RED}Select an action:${NC}"
echo -e "${RED}1) Install node${NC}"
echo -e "${RED}2) Register node${NC}"
echo -e "${RED}3) View logs${NC}"
echo -e "${RED}4) Restart node${NC}"
echo -e "${RED}5) Update node${NC}"
echo -e "${RED}6) Remove node${NC}"

echo -e "${RED}Enter number:${NC} "
read choice

case $choice in
    1)
        echo -e "${RED}Installing dependencies...${NC}"
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt install iptables-persistent
        sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
        
        echo -e "${RED}Checking Docker and Docker-Compose...${NC}"
        if ! bash <(curl -fsSL https://raw.githubusercontent.com/Evenorchik/blockcast/refs/heads/main/docker_inst.sh); then
          echo -e "${RED}Failed to install Docker/Compose${NC}" >&2
          exit 1
        fi
        
        git clone https://github.com/Blockcast/beacon-docker-compose.git
        cd beacon-docker-compose

        # Determine which compose syntax is available
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo -e "${RED}Error: neither 'docker-compose' nor 'docker compose' found.${NC}" >&2
          exit 1
        fi
        
        $DC up -d
      
        cd ~
        # Final output
        echo -e "${RED}-----------------------------------------------------------------------${NC}"
        echo -e "${RED}Command to check logs:${NC}"
        echo "docker logs -f blockcastd"
        echo -e "${RED}-----------------------------------------------------------------------${NC}"
        echo -e "${RED}CRYPTO FORTO in one place!${NC}"
        echo -e "${RED}My channel https://x.com/Evenorchik${NC}"
        sleep 2
        docker logs -f blockcastd   
        ;;
    2)
        echo -e "${RED}Fetching registration data...${NC}"
        cd beacon-docker-compose
        sleep 2

        # Determine which compose syntax is available
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo -e "${RED}Error: neither 'docker-compose' nor 'docker compose' found.${NC}" >&2
          exit 1
        fi
        
        $DC exec blockcastd blockcastd init
        cd ~
        ;;
    3)
        docker logs -f blockcastd
        ;;
    4)
        echo -e "${RED}Restarting node containers...${NC}"
        cd beacon-docker-compose

        # Determine which compose syntax is available
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo -e "${RED}Error: neither 'docker-compose' nor 'docker compose' found.${NC}" >&2
          exit 1
        fi
        
        $DC restart
        cd ~
        sleep 2
        docker logs -f blockcastd
        ;;
    5)
        echo -e "${RED}Your node is up to date!${NC}"
        ;;
    6)
        echo -e "${RED}Removing Blockcast node...${NC}"
        cd ~/beacon-docker-compose

        # Determine which compose syntax is available
        if command -v docker-compose &> /dev/null; then
          DC="docker-compose"
        elif docker compose version &> /dev/null; then
          DC="docker compose"
        else
          echo -e "${RED}Error: neither 'docker-compose' nor 'docker compose' found.${NC}" >&2
          exit 1
        fi
        
        $DC down --rmi all --volumes --remove-orphans
        cd ~
        rm -rf beacon-docker-compose
        rm -rf ~/.blockcast
        ;;
    *)
        echo -e "${RED}Invalid selection! Please choose an option from the menu.${NC}"
        ;;
esac

#!/bin/bash

print_message() {
  local COLOR=$1
  local MESSAGE=$2
  local RESET="\033[0m"
  echo -e "${COLOR}${MESSAGE}${RESET}"
}

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"

print_message "$BLUE" "================================================="
print_message "$GREEN" "🚀 Cloud9 Installation Script By Priv8 Tools 🌟"
print_message "$BLUE" "================================================="

print_message "$YELLOW" "🔍 Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
else
  print_message "$RED" "❌ Unable to detect Linux distribution. Exiting..."
  exit 1
fi

print_message "$BLUE" "🖥️ Detected OS: $OS"

if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
  print_message "$RED" "❌ Unsupported OS: $OS. This script supports only Ubuntu and Debian. Exiting..."
  exit 1
fi

print_message "$YELLOW" "⚙️ Step 1: Updating system..."
sudo apt update -y && sudo apt upgrade -y && sudo apt install snapd git curl -y
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to update or install dependencies."
  exit 1
fi

print_message "$YELLOW" "🐳 Step 2: Installing Docker..."
sudo snap install docker
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to install Docker."
  exit 1
fi

print_message "$YELLOW" "📁 Step 3: Preparing workspace directory..."
mkdir -p ~/cloud9
sudo chmod 777 ~/cloud9

print_message "$YELLOW" "📥 Step 4: Pulling Cloud9 Docker image..."
sudo docker pull lscr.io/linuxserver/cloud9:latest
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to pull Cloud9 image."
  exit 1
fi

USERNAME="kontol"
PASSWORD="kontol"

print_message "$YELLOW" "🚀 Step 5: Running Cloud9 container..."
sudo docker rm -f Priv8-Tools 2>/dev/null

sudo docker run -d \
  --name=Priv8-Tools \
  -e USERNAME=$USERNAME \
  -e PASSWORD=$PASSWORD \
  -p 8000:8000 \
  -v ~/cloud9:/config \
  lscr.io/linuxserver/cloud9:latest

if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Failed to run Cloud9 container."
  exit 1
fi

print_message "$YELLOW" "⏳ Waiting 30 seconds before configuration..."
sleep 30

print_message "$YELLOW" "⚙️ Configuring Cloud9 container..."
sudo docker exec Priv8-Tools bash -c "
  apt update -y && \
  apt upgrade -y && \
  apt install wget php-cli php-curl -y && \
  cd /config/.c9/ && \
  rm -rf user.settings && \
  wget https://raw.githubusercontent.com/daniandriyan18/cloud9/refs/heads/main/user.settings
"
if [ $? -ne 0 ]; then
  print_message "$RED" "❌ Configuration failed inside container."
  exit 1
fi

print_message "$YELLOW" "♻️ Restarting container..."
sudo docker restart Priv8-Tools

PUBLIC_IP=$(curl -s ifconfig.me)
[ -z "$PUBLIC_IP" ] && PUBLIC_IP="localhost"

print_message "$BLUE" "==========================================="
print_message "$GREEN" "🎉 Cloud9 Setup Completed Successfully 🎉"
print_message "$BLUE" "==========================================="
print_message "$YELLOW" "🌐 Access Cloud9 at: http://$PUBLIC_IP:8000"
print_message "$YELLOW" "🔑 Username: $USERNAME"
print_message "$YELLOW" "🔑 Password: $PASSWORD"
print_message "$YELLOW" "📁 Workspace Directory: ~/cloud9"
print_message "$YELLOW" "=========================================="

#!/bin/bash

# ==========================================
# Cloud9 IDE Installer (Self-Hosted Version)
# Auto login: admin / Kontol123#AA
# ==========================================

echo "=== Cloud9 Installer ==="

# 1. Update sistem dan install dependensi
echo "[1/5] Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential libssl-dev git curl

# 2. Install Node.js 0.10 (legacy for Cloud9 SDK)
echo "[2/5] Installing Node.js v0.10..."
curl -fsSL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
sudo apt install -y nodejs

# 3. Clone Cloud9 SDK
echo "[3/5] Cloning Cloud9 SDK..."
git clone https://github.com/c9/core.git ~/cloud9
cd ~/cloud9

# 4. Install SDK dependencies
echo "[4/5] Installing Cloud9 dependencies..."
scripts/install-sdk.sh

# 5. Buat systemd service (opsional)
echo "[5/5] Creating systemd service..."

sudo tee /etc/systemd/system/cloud9.service > /dev/null <<EOF
[Unit]
Description=Cloud9 IDE
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/cloud9
ExecStart=/usr/bin/node server.js -p 8181 -a admin:Kontol123#AA
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable dan jalankan service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable cloud9
sudo systemctl start cloud9

# Selesai
echo ""
echo "=== Cloud9 Installed Successfully! ==="
echo "Akses IDE di: http://<your-server-ip>:8181"
echo "Login: admin"
echo "Password: Kontol123#AA"
echo ""
echo "Untuk cek status: sudo systemctl status cloud9"

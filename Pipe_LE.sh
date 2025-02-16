#!/bin/bash

printf "\n"
cat <<EOF

  ('-.      .-')    ('-. .-.             
  ( OO ).-. ( OO ). ( OO )  /             
  / . --. /(_)---\_),--. ,--. ,--. ,--.   
  | \-.  \ /    _ | |  | |  | |  | |  |   
.-'-'  |  |\  :` `. |   .|  | |  | | .-') 
 \| |_.'  | '..`''.)|       | |  |_|( OO )
  |  .-.  |.-._)   \|  .-.  | |  | | `-' /
  |  | |  |\       /|  | |  |('  '-'(_.-' 
  `--' `--' `-----' `--' `--'  `-----'    

EOF

printf "\n\n"

# Define colors
GREEN="\033[0;32m"
RESET="\033[0m"

# Print welcome message
printf "${GREEN}"
printf "1-Click Node Run Tool For Pipe Network\n"
printf "Join https://telegram.dog/Lootersera_th For Updates\n"
printf "${RESET}"

# Check if the "pipe" screen session exists
if screen -list | grep -q "pipe-le"; then
    echo -e "\n✅ Existing 'pipe-le' screen session found! Resuming it..."
    screen -r pipe-le
    exit 0
fi

echo "==========================================================="
echo "🚀  Welcome to the PiPe Network Node Installer 🚀"
echo "==========================================================="
echo ""
echo "✨ Give Some Details For Node Run!"
echo ""

# Ask the user for input
read -p "🔢 Enter RAM allocation (in GB, e.g., 8): " RAM
read -p "💾 Enter Disk allocation (in GB, e.g., 500): " DISK
read -p "🔑 Enter your Solana wallet Address: " PUBKEY

# Ask for the referral code, but enforce the default one
read -p "🫂 Enter your Referral Code: " USER_REFERRAL
REFERRAL_CODE="30f20ac82d261f39"  # Your default referral code

# Print the referral code that will actually be used
echo -e "\n✅ Using Referral Code: $REFERRAL_CODE (default enforced)"

# Confirm details
echo -e "\n📌 Configuration Summary:"
echo "   🔢 RAM: ${RAM}GB"
echo "   💾 Disk: ${DISK}GB"
echo "   🔑 PubKey: ${PUBKEY}"
echo "   🫂 Referral Code: ${REFERRAL_CODE}"
read -p "⚡ Proceed with installation? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "❌ Installation canceled!"
    exit 1
fi

# Update system
echo -e "\n🔄 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install dependencies
echo -e "\n⚙️ Installing required dependencies..."
sudo apt install -y curl wget jq unzip screen

# Create a directory for PiPe node
echo -e "\n📂 Setting up PiPe node directory..."
mkdir -p ~/pipe-node && cd ~/pipe-node

# Download the latest PiPe Network binary (pop)
echo -e "\n⬇️ Downloading PiPe Network node (pop)..."
curl -L -o pop "https://dl.pipecdn.app/v0.2.5/pop"

# Make binary executable
chmod +x pop

# Verify installation
echo -e "\n🔍 Verifying pop binary..."
./pop --version || { echo "❌ Error: pop binary is not working!"; exit 1; }

# Create download cache directory
echo -e "\n📂 Creating download cache directory..."
mkdir -p download_cache

# Sign up using the referral code
echo -e "\n📌 Signing up for PiPe Network using referral..."
./pop --signup-by-referral-route "$REFERRAL_CODE"
if [ $? -ne 0 ]; then
    echo "❌ Error: Signup failed!"
    exit 1
fi

# Generate referral
echo -e "\n🫂 Your Referral Code..."
./pop --gen-referral-route

# Start PiPe node
echo -e "\n🚀 Starting PiPe Network node..."
sudo ./pop --ram "$RAM" --max-disk "$DISK" --cache-dir /data --pubKey "$PUBKEY" &

# Save node information
echo -e "\n📜 Saving node information..."
cat <<EOF > ~/node_info.json
{
    "RAM": "$RAM",
    "Disk": "$DISK",
    "PubKey": "$PUBKEY",
    "Referral": "$REFERRAL_CODE"
}
EOF

echo -e "\n✅ Node information saved! (nano ~/node_info.json to edit)"

# Create a new screen session
echo -e "\n📟 Creating a new screen session named 'pipe-le'..."
screen -dmS pipe-le bash -c "
    cd ~/pipe-node
    while true; do
        echo '📊 Node Status:'
        ./pop --status
        echo ''
        echo '🏆 Check Points:'
        ./pop --points
        echo ''
        echo '🔄 Updating in 10 seconds...'
        sleep 10
    done
"

echo -e "\n✅ PiPe Node is now running inside 'pipe-le' screen session."
echo "👉 To view logs, use: screen -r pipe-le"
echo "👉 To detach from screen, press: Ctrl+A then D"

#!/bin/bash

# -------- CONFIG --------
# Set your OpenVPN binary path (use 'which openvpn' if installed via Homebrew)
OPENVPN_BIN="openvpn_path_here"

# Set your OpenVPN config file path (.ovpn)
CONFIG_FILE="openvpn_config_path_here"

# Path to your credentials file with username and static password
AUTH_FILE="$HOME/.openvpn-auth"
# Create this file with:
# line 1 -> username
# line 2 -> password
# Permissions must be 600 (read/write only for user)
# ------------------------

# Check OTP argument
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <OTP>"
  exit 1
fi
OTP="$1"

# Read username and static password
USERNAME=$(sed -n '1p' "$AUTH_FILE")
STATIC_PASSWORD=$(sed -n '2p' "$AUTH_FILE")
VPN_PASSWORD="${STATIC_PASSWORD}${OTP}"

# Create temporary auth file
TMP_AUTH=$(mktemp)
chmod 600 "$TMP_AUTH"
echo -e "${USERNAME}\n${VPN_PASSWORD}" > "$TMP_AUTH"

# Connect VPN
echo "Starting OpenVPN securely..."
echo "You will be prompted for macOS sudo password."
echo ""

sudo "$OPENVPN_BIN" --config "$CONFIG_FILE" --auth-user-pass "$TMP_AUTH"

# Remove temporary auth file
rm -f "$TMP_AUTH"

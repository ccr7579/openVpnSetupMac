#!/bin/bash

# ------------------------------
# Automated OpenVPN setup for macOS
# ------------------------------

echo "🔹 Starting OpenVPN Installer Script..."

# --- 1. Install Homebrew if missing ---
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi

# --- 2. Install OpenVPN ---
if ! command -v openvpn >/dev/null 2>&1; then
    echo "Installing OpenVPN..."
    brew install openvpn
else
    echo "OpenVPN already installed."
fi

OPENVPN_BIN="$(which openvpn)"
echo "OpenVPN binary located at: $OPENVPN_BIN"

# --- 3. Create secure auth file ---
AUTH_FILE="$HOME/.openvpn-auth"

if [[ -f "$AUTH_FILE" ]]; then
    echo "Auth file already exists at $AUTH_FILE"
else
    echo "Creating secure auth file at $AUTH_FILE"
    read -p "Enter your VPN username: " VPN_USER
    read -s -p "Enter your static VPN password (not OTP): " VPN_PASS
    echo ""
    echo -e "${VPN_USER}\n${VPN_PASS}" > "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    echo "✅ Auth file created securely with permissions 600."
fi

# --- 4. Create generic connectVPN.sh script ---
VPN_SCRIPT="$HOME/connectVPN.sh"

cat > "$VPN_SCRIPT" << 'EOF'
#!/bin/bash

# -------- CONFIG --------
OPENVPN_BIN="$(which openvpn)"
CONFIG_FILE="$1"
AUTH_FILE="$2"
# ------------------------

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <path-to-config.ovpn> <path-to-auth-file> <OTP>"
  echo "Example: $0 ~/vpnconfig.ovpn ~/.openvpn-auth 123456"
  exit 1
fi

OTP="$3"

# Validate files
if [[ ! -x "$OPENVPN_BIN" ]]; then
  echo "❌ OpenVPN binary not found at: $OPENVPN_BIN"
  exit 1
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi
if [[ ! -f "$AUTH_FILE" ]]; then
  echo "❌ Auth file not found: $AUTH_FILE"
  exit 1
fi

PERM=$(stat -f "%Lp" "$AUTH_FILE")
if [[ "$PERM" != "600" ]]; then
  echo "❌ Auth file permissions must be 600"
  exit 1
fi

# Read credentials and combine OTP
USERNAME=$(sed -n '1p' "$AUTH_FILE")
STATIC_PASSWORD=$(sed -n '2p' "$AUTH_FILE")
VPN_PASSWORD="${STATIC_PASSWORD}${OTP}"

# Create temporary auth file
TMP_AUTH=$(mktemp)
chmod 600 "$TMP_AUTH"
echo -e "${USERNAME}\n${VPN_PASSWORD}" > "$TMP_AUTH"

# Connect VPN
echo "🔐 Starting OpenVPN securely..."
echo "You will be prompted for macOS sudo password."
echo ""
sudo "$OPENVPN_BIN" --config "$CONFIG_FILE" --auth-user-pass "$TMP_AUTH"

# Remove temp file
rm -f "$TMP_AUTH"
EOF

chmod +x "$VPN_SCRIPT"
echo " Generic VPN script created at $VPN_SCRIPT"

echo ""
echo " Setup complete!"
echo "Use it like this:"
echo "~/connectVPN.sh <path-to-config.ovpn> ~/.openvpn-auth <OTP>"
echo "Example:"
echo "~/connectVPN.sh ~/vpnconfig.ovpn ~/.openvpn-auth 123456"

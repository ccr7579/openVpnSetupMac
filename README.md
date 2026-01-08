# Secure OpenVPN on macOS — Quick Setup

## Overview
A concise, step-by-step guide to install OpenVPN using Homebrew, create a secure credentials file, and run a helper script to connect to your VPN on macOS. The script reads your username and static password from a protected file (~/.openvpn-auth) and accepts a one-time password (OTP) as a command-line argument.

## Prerequisites
- macOS (Intel or Apple Silicon)
- Homebrew installed (see install step if not already present)
- An OpenVPN configuration file (.ovpn) from your VPN provider or administrator
- A username, static password (no OTP) and OTP generator
- The connect script (`connectVPN.sh`) saved to your home directory

## Install Homebrew (if needed)
Run the official installer and verify Homebrew is available:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew --version
```

## Install OpenVPN

```bash
brew install openvpn
```

Find the OpenVPN binary path (use this in the script if needed):

```bash
which openvpn
```

## Configuration file (.ovpn)
Copy your .ovpn file to a convenient, secure location. Example:

```bash
$HOME/vpnconfig.ovpn
```

## Create a credentials file (secure)

1. Create the file `~/.openvpn-auth` with two lines:
   - Line 1: VPN username
   - Line 2: Static password (the password only; do NOT include OTP)

Example contents:

```
myusername
mypassword
```

2. Set strict permissions so only your user can read it:

```bash
chmod 600 ~/.openvpn-auth
```

## Save and make the connect script executable

1. Save `connectVPN.sh` to your home directory (`~/connectVPN.sh`).
2. Ensure the script is executable:

```bash
chmod +x ~/connectVPN.sh
```

## Usage (connect)

Run the script and pass your OTP as the only argument. Example:

```bash
~/connectVPN.sh 123456
```

Notes:
- Replace `123456` with your current one-time password (OTP).
- The script reads your username and static password from `~/.openvpn-auth` and combines them with the OTP you provide.
- Temporary files created by the script are removed automatically after use.
- You may be prompted for your macOS sudo password when the script needs elevated privileges.

## Security recommendations
- Use `chmod 600` on `~/.openvpn-auth` to prevent other users from reading your credentials.
- Do not store OTPs in the credentials file — supply them at runtime.
- Consider using a macOS keychain or a password manager for long-term credential storage.
- Review the `connectVPN.sh` contents before running to ensure it matches your security policy.

## Troubleshooting
- If OpenVPN is not found, ensure Homebrew's bin path is on your `PATH` or update `OPENVPN_BIN` in the script with the output of `which openvpn`.
- If the VPN does not connect, double-check the .ovpn file, credentials, and the OTP generator clock sync.
- Check system logs (Console.app) or run OpenVPN in verbose mode for more details.

## License & Attribution
- This document is provided as-is; adjust and reuse as needed. The repository owner is responsible for the script and configuration.

End of README update.

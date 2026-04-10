#!/data/data/com.termux/files/usr/bin/sh

echo "[*] Updating and Upgrading Termux packages..."
pkg update -y && pkg upgrade -y

echo "[*] Installing dependencies (termux-api, libusb, curl)..."
pkg install termux-api libusb curl -y

echo "[*] Downloading patched Heimdall binary..."
# This points directly to the binary in your repository
curl -L https://githubusercontent.com -o $PREFIX/bin/heimdall-binary
chmod +x $PREFIX/bin/heimdall-binary

echo "[*] Creating the no-root wrapper script..."
cat << 'EOF' > $PREFIX/bin/heimdall
#!/data/data/com.termux/files/usr/bin/sh
BINARY="$PREFIX/bin/heimdall-binary"

# 1. Bypass USB check for version/help
if [ -z "$1" ] || [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "version" ]; then
    $BINARY "$@"
    exit 0
fi

# 2. Command Validation: Prevents looking for a device if the command is a typo
VALID_CMDS="detect|device-info|download-pit|flash|print-pit|close-pc-screen|help|version"
if ! echo "$1" | grep -Eq "^($VALID_CMDS)$"; then
    echo "Error: '$1' is unrecognized. Use 'heimdall help' for help."
    exit 1
fi

# 3. Handle incomplete valid commands (e.g., 'flash' with no files)
if { [ "$1" = "flash" ] || [ "$1" = "download-pit" ]; } && [ -z "$2" ]; then
    $BINARY help "$1"
    exit 0
fi

# 4. USB Handshake Logic
DEV=$(termux-usb -l | grep -o '/dev/bus/usb/[0-9]*/[0-9]*' | head -n 1)

if [ -z "$DEV" ]; then
    echo "[-] No Samsung device found. Check OTG and Download Mode."
    exit 1
fi

echo "[!] Device found: $DEV"
termux-usb -r "$DEV"

echo "[?] Tap 'OK' on the system popup, then press [ENTER] to continue..."
read dummy

# 5. Final execution with FD injection via termux-usb -e
termux-usb -e "$DEV" $BINARY "$@"
EOF

chmod +x $PREFIX/bin/heimdall

echo "[+] Success! You can now use 'heimdall' without root."
echo "[+] Connect your phone and try: heimdall detect"

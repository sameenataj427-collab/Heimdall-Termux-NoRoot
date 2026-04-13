#!/data/data/com.termux/files/usr/bin/sh

echo "=========================================="
echo "🚀 HEIMDALL NO-ROOT SETUP"
echo "=========================================="

# 1. Attempt to fix any existing broken packages (Safe for all users)
echo "[*] Checking system health..."
apt --fix-broken install -y > /dev/null 2>&1

# 2. Install only the essential dependencies
# We use 'pkg install' as it handles the repo mirrors better for new users
echo "[*] Installing dependencies (libusb, termux-api)..."
pkg install -y libusb termux-api binutils 

# 3. Check for the termux-api helper
if ! command -v termux-usb > /dev/null; then
    echo "[!] Warning: termux-usb not found."
    echo "[!] Please ensure you have the 'Termux:API' app installed from F-Droid."
fi

echo "[*] Installing Heimdall components..."

# 4. Move the wrapper script (Brain)
if [ -f "./heimdall" ]; then
    mv ./heimdall $PREFIX/bin/
    chmod +x $PREFIX/bin/heimdall
    echo "[+] Wrapper script installed."
else
    echo "[!] Error: 'heimdall' file missing from download."
    exit 1
fi

# 5. Move the binary engine (Engine)
if [ -f "./heimdall-binary" ]; then
    mv ./heimdall-binary $PREFIX/bin/
    chmod +x $PREFIX/bin/heimdall-binary
    echo "[+] Binary engine installed."
else
    echo "[!] Error: 'heimdall-binary' file missing from download."
    exit 1
fi

echo "=========================================="
echo "✅ SETUP SUCCESSFUL"
echo "=========================================="
echo "Usage: Type 'heimdall' to start."
echo "Note: Connect your phone in Download Mode via OTG."

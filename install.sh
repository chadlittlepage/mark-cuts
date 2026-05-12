#!/bin/bash
# Terminal installer for mark_cuts. Copies the Resolve script into the
# system-wide DaVinci Resolve scripts folder. Re-runnable.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/mark_cuts.py"
DEST_DIR="/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit"

if [ ! -f "$SOURCE" ]; then
    echo "ERROR: mark_cuts.py not found next to install.sh"
    exit 1
fi

echo "Installing mark_cuts to:"
echo "  $DEST_DIR"
echo ""
echo "You will be prompted for your password (needed to write into /Library)."
echo ""

sudo mkdir -p "$DEST_DIR"
sudo cp "$SOURCE" "$DEST_DIR/mark_cuts.py"
sudo chmod 644 "$DEST_DIR/mark_cuts.py"

echo ""
echo "Installed."
echo ""
echo "Next steps inside DaVinci Resolve:"
echo "  1. Preferences > System > General > External scripting using: Local"
echo "  2. Save and restart Resolve"
echo "  3. Workspace > Scripts > Edit > mark_cuts"
echo ""
echo "Python 3 must be installed from python.org (not Homebrew)."

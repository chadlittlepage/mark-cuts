#!/bin/bash
# Terminal installer for mark_cuts.
#
# Installs to /Library/.../Fusion/Scripts/Utility/ only. Resolve shows
# Utility scripts at the top level on every page (Edit, Color, Fusion,
# Deliver) so a single install reaches every page with no duplicates.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/mark_cuts.py"
DEST_DIR="/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility"

if [ ! -f "$SOURCE" ]; then
    echo "ERROR: mark_cuts.py not found next to install.sh"
    exit 1
fi

echo "Installing mark_cuts to:"
echo "  $DEST_DIR/"
echo ""
echo "You will be prompted for your password (needed to write into /Library)."
echo ""

sudo mkdir -p "$DEST_DIR"
sudo cp "$SOURCE" "$DEST_DIR/mark_cuts.py"
sudo chmod 644 "$DEST_DIR/mark_cuts.py"

# Python 3 from python.org check
if [ ! -d "/Library/Frameworks/Python.framework" ]; then
    PYTHON_WARNING=" *** Python 3 from python.org was NOT detected on this Mac.
     Install it from https://www.python.org/downloads/ before running.
     (Homebrew Python will not work - Resolve cannot see it.)
"
    echo ""
    echo "WARNING: Python 3 from python.org not detected."
    echo "  Install from https://www.python.org/downloads/"
else
    PYTHON_WARNING=""
fi

# Drop next-steps doc on Desktop
if [ -d "$HOME/Desktop" ]; then
    cat > "$HOME/Desktop/Mark_Cuts_NEXT_STEPS.txt" << NEXTSTEPS
mark_cuts - Next Steps
======================
$PYTHON_WARNING
mark_cuts has been installed. It will appear at the top of
Workspace > Scripts on every Resolve page (Edit, Color, Fusion, Deliver).

TWO MANUAL STEPS REMAIN inside DaVinci Resolve:

  1. Enable external scripting
     - Open DaVinci Resolve
     - Preferences > System > General
     - Set "External scripting using" to "Local"
     - Save
     - Quit and re-open Resolve

  2. Run the script
     - Open a project with a timeline
     - Workspace > Scripts > mark_cuts

REQUIREMENT: Python 3 must be installed from python.org (not Homebrew).
   https://www.python.org/downloads/

Once everything works you can delete this file.

---
Created by Chad Littlepage
chad.littlepage@gmail.com  |  323.974.0444
NEXTSTEPS
fi

echo ""
echo "Installed. See Mark_Cuts_NEXT_STEPS.txt on your Desktop for the two"
echo "remaining manual steps inside DaVinci Resolve."

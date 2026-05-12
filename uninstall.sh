#!/bin/bash
# Remove every copy of mark_cuts.py the installer placed on this Mac,
# the pkg receipt, and the Next-Steps Desktop note.
set +e

SCRIPTS_SUBPATH="Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts"
PAGES="Utility Edit Color Comp Deliver"

echo "Uninstalling mark_cuts..."
echo ""
echo "You will be prompted for your password (needed to remove from /Library)."
echo ""

# System-wide
for PAGE in $PAGES; do
    sudo rm -f "/$SCRIPTS_SUBPATH/$PAGE/mark_cuts.py"
done

# Current user
for PAGE in $PAGES; do
    rm -f "$HOME/$SCRIPTS_SUBPATH/$PAGE/mark_cuts.py"
done

# Other users (best-effort — TCC may block on macOS 15+)
for USER_HOME in /Users/*; do
    [ ! -d "$USER_HOME/Library" ] && continue
    UNAME=$(basename "$USER_HOME")
    [ "$UNAME" = "Shared" ] && continue
    [ "$USER_HOME" = "$HOME" ] && continue
    for PAGE in $PAGES; do
        sudo rm -f "$USER_HOME/$SCRIPTS_SUBPATH/$PAGE/mark_cuts.py" 2>/dev/null
    done
done

# Installer receipt
sudo pkgutil --forget com.chadlittlepage.mark-cuts 2>/dev/null

# Desktop note
rm -f "$HOME/Desktop/Mark_Cuts_NEXT_STEPS.txt"

echo ""
echo "Uninstalled."
echo ""
echo "To strip the blue 'Cut' markers from a timeline: in Resolve's marker"
echo "list, filter by color Blue + name 'Cut', select all, and delete."

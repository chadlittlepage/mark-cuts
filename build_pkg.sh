#!/bin/bash
# Build Mark_Cuts_Installer.pkg
#
# Usage:
#   ./build_pkg.sh             unsigned (testing only - will trip Gatekeeper)
#   ./build_pkg.sh --sign      signed with Developer ID Installer
#   ./build_pkg.sh --notarize  signed + notarized + stapled (distribution-ready)
#
# Notarization requires a stored keychain profile named "mark-cuts-notary":
#   xcrun notarytool store-credentials "mark-cuts-notary" \
#       --apple-id "you@example.com" --team-id "72J767FV46" \
#       --password "app-specific-password"
set -e

VERSION="1.0.3"
APP_NAME="Mark_Cuts_Installer"
BUNDLE_ID="com.chadlittlepage.mark-cuts"
SIGN_ID="Developer ID Installer: Chad Littlepage (72J767FV46)"
NOTARY_PROFILE="chads-davinci-notary"

# Install to Utility/ only. Resolve shows Utility scripts at the top level
# on every page (Edit, Color, Fusion, Deliver), so one install reaches
# every page with zero duplicates. Installing to per-page folders + per-user
# locations (as v1.0.1 did) caused 8-10x duplicates in the Scripts menu
# because Resolve reads both /Library and ~/Library.
INSTALL_LOCATION="/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility"

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
STAGING="$BUILD_DIR/staging"
PKG_DIR="$BUILD_DIR/pkg"
COMPONENT_PKG="$PKG_DIR/$APP_NAME-component.pkg"
UNSIGNED_PKG="$PKG_DIR/$APP_NAME-unsigned.pkg"
OUTPUT_PKG="$BUILD_DIR/$APP_NAME-v$VERSION.pkg"

SIGN=false
NOTARIZE=false
case "${1:-}" in
    --sign) SIGN=true ;;
    --notarize) SIGN=true; NOTARIZE=true ;;
    "") ;;
    *) echo "Unknown option: $1"; exit 2 ;;
esac

echo "========================================"
echo "  Building $APP_NAME v$VERSION"
[ "$SIGN" = true ] && echo "  Mode: signed"
[ "$NOTARIZE" = true ] && echo "  Mode: signed + notarized"
[ "$SIGN" = false ] && echo "  Mode: unsigned (testing only)"
echo "========================================"

# --- Step 1: stage payload ---
echo ""
echo "[1/4] Staging installer payload..."
rm -rf "$STAGING" "$PKG_DIR"
mkdir -p "$STAGING$INSTALL_LOCATION"
mkdir -p "$PKG_DIR"

cp "$PROJECT_DIR/mark_cuts.py" "$STAGING$INSTALL_LOCATION/mark_cuts.py"
chmod 644 "$STAGING$INSTALL_LOCATION/mark_cuts.py"
echo "  Staged: mark_cuts.py -> $INSTALL_LOCATION"

# --- Step 2: build component pkg ---
echo ""
echo "[2/4] Building component package..."

# Make sure postinstall is executable
chmod +x "$PROJECT_DIR/pkg/scripts/postinstall"

pkgbuild \
    --root "$STAGING" \
    --identifier "$BUNDLE_ID" \
    --version "$VERSION" \
    --scripts "$PROJECT_DIR/pkg/scripts" \
    --install-location "/" \
    "$COMPONENT_PKG"

# --- Step 3: build product archive with welcome / conclusion screens ---
echo ""
echo "[3/4] Building product archive..."

cat > "$PKG_DIR/distribution.xml" << DISTXML
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>mark_cuts v$VERSION</title>
    <organization>com.chadlittlepage</organization>
    <domains enable_localSystem="true" enable_currentUserHome="false"/>
    <options customize="never" require-scripts="true" rootVolumeOnly="true"/>
    <welcome file="welcome.html" mime-type="text/html"/>
    <conclusion file="conclusion.html" mime-type="text/html"/>
    <license file="LICENSE.txt" mime-type="text/plain"/>
    <choices-outline>
        <line choice="default">
            <line choice="$BUNDLE_ID"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="$BUNDLE_ID" visible="false">
        <pkg-ref id="$BUNDLE_ID"/>
    </choice>
    <pkg-ref id="$BUNDLE_ID" version="$VERSION" onConclusion="none">$APP_NAME-component.pkg</pkg-ref>
</installer-gui-script>
DISTXML

# Copy LICENSE into resources so productbuild can find it
cp "$PROJECT_DIR/LICENSE" "$PROJECT_DIR/pkg/resources/LICENSE.txt"

productbuild \
    --distribution "$PKG_DIR/distribution.xml" \
    --resources "$PROJECT_DIR/pkg/resources" \
    --package-path "$PKG_DIR" \
    "$UNSIGNED_PKG"

# --- Step 4: sign / notarize / output ---
echo ""
echo "[4/4] Finalizing..."

if [ "$SIGN" = true ]; then
    echo "  Signing with: $SIGN_ID"
    productsign --sign "$SIGN_ID" "$UNSIGNED_PKG" "$OUTPUT_PKG"

    if [ "$NOTARIZE" = true ]; then
        echo ""
        echo "  Submitting for notarization (this can take 30-120 seconds)..."
        if ! xcrun notarytool submit "$OUTPUT_PKG" \
                --keychain-profile "$NOTARY_PROFILE" --wait; then
            echo ""
            echo "  WARNING: notarization failed or profile '$NOTARY_PROFILE' is not stored."
            echo "  Run this once to set it up:"
            echo "    xcrun notarytool store-credentials \"$NOTARY_PROFILE\" \\"
            echo "        --apple-id YOUR_APPLE_ID --team-id 72J767FV46 --password APP_SPECIFIC_PASSWORD"
            exit 1
        fi

        echo ""
        echo "  Stapling notarization ticket..."
        xcrun stapler staple "$OUTPUT_PKG"
        xcrun stapler validate "$OUTPUT_PKG"
    fi
else
    cp "$UNSIGNED_PKG" "$OUTPUT_PKG"
fi

# Cleanup intermediates but keep the final pkg
rm -f "$PROJECT_DIR/pkg/resources/LICENSE.txt"

PKG_SIZE=$(du -sh "$OUTPUT_PKG" | cut -f1)
echo ""
echo "========================================"
echo "  Done: $OUTPUT_PKG ($PKG_SIZE)"
echo "========================================"

#!/bin/bash
# Hadir — Build & Launch Script (run on Mac with Xcode 15+)
# Usage: chmod +x build_and_run.sh && ./build_and_run.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ██╗  ██╗ █████╗ ██████╗ ██╗██████╗ "
echo "  ██║  ██║██╔══██╗██╔══██╗██║██╔══██╗"
echo "  ███████║███████║██║  ██║██║██████╔╝"
echo "  ██╔══██║██╔══██║██║  ██║██║██╔══██╗"
echo "  ██║  ██║██║  ██║██████╔╝██║██║  ██║"
echo "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
echo "  AI Clinical Companion for Puskesmas Doctors"
echo "  Swift Student Challenge 2026"
echo ""

# ---------- Prerequisites ----------

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Error: Xcode not found. Install Xcode 15+ from the App Store.${NC}"
    exit 1
fi

XCODE_VER=$(xcodebuild -version | head -1)
SWIFT_VER=$(swift --version 2>&1 | head -1)
echo -e "${GREEN}✓ $XCODE_VER${NC}"
echo -e "${GREEN}✓ $SWIFT_VER${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$SCRIPT_DIR/Hadir.swiftpm"

if [ ! -f "$APP_DIR/Package.swift" ]; then
    echo -e "${RED}Error: Hadir.swiftpm not found at $APP_DIR${NC}"
    exit 1
fi

# ---------- Choose target ----------

echo "Choose a target:"
echo "  1) iPad Simulator (iPad Pro 13-inch M4) [recommended]"
echo "  2) iPhone Simulator (iPhone 16 Pro)"
echo "  3) List available simulators"
echo "  4) Open in Swift Playgrounds (simplest)"
read -p "Enter choice [1]: " CHOICE
CHOICE=${CHOICE:-1}

case $CHOICE in
  3)
    echo -e "\n${YELLOW}Available iOS Simulators:${NC}"
    xcrun simctl list devices available | grep -E "iPad|iPhone"
    exit 0
    ;;
  4)
    echo -e "\n${YELLOW}Opening in Swift Playgrounds...${NC}"
    open "$APP_DIR"
    echo -e "${GREEN}Opened! Allow microphone access when prompted.${NC}"
    exit 0
    ;;
  2)
    DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro,OS=latest"
    DEVICE_LABEL="iPhone 16 Pro"
    ;;
  *)
    DESTINATION="platform=iOS Simulator,name=iPad Pro 13-inch (M4),OS=latest"
    DEVICE_LABEL="iPad Pro 13-inch (M4)"
    ;;
esac

# ---------- Build ----------

echo ""
echo -e "${YELLOW}Building Hadir for $DEVICE_LABEL...${NC}"
echo ""

cd "$APP_DIR"

# Install xcpretty for nicer output (optional)
if command -v xcpretty &> /dev/null; then
    BUILD_CMD="xcodebuild build -scheme Hadir -destination '$DESTINATION' -configuration Debug CODE_SIGNING_ALLOWED=NO | xcpretty --color"
else
    BUILD_CMD="xcodebuild build -scheme Hadir -destination '$DESTINATION' -configuration Debug CODE_SIGNING_ALLOWED=NO"
fi

eval $BUILD_CMD

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build succeeded!${NC}"
else
    echo ""
    echo -e "${RED}✗ Build failed. Check output above.${NC}"
    exit 1
fi

# ---------- Launch on Simulator ----------

echo ""
echo -e "${YELLOW}Launching on simulator...${NC}"

# Boot the simulator
SIM_UDID=$(xcrun simctl list devices available | grep "$DEVICE_LABEL" | head -1 | grep -oE '\(([0-9A-F-]{36})\)' | tr -d '()')

if [ -z "$SIM_UDID" ]; then
    echo -e "${YELLOW}Could not find simulator UDID. Opening Simulator app...${NC}"
    open -a Simulator
else
    xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
    open -a Simulator

    # Find and install the built app
    BUILD_DIR=$(xcodebuild -showBuildSettings -scheme Hadir -destination "$DESTINATION" -configuration Debug CODE_SIGNING_ALLOWED=NO 2>/dev/null | grep "BUILT_PRODUCTS_DIR" | awk '{print $3}')
    APP_PATH="$BUILD_DIR/Hadir.app"

    if [ -d "$APP_PATH" ]; then
        echo "Installing app on simulator..."
        xcrun simctl install "$SIM_UDID" "$APP_PATH"
        xcrun simctl launch "$SIM_UDID" "com.faridnahdi.Hadir"
        echo -e "${GREEN}✓ Hadir is running on $DEVICE_LABEL!${NC}"
    else
        echo -e "${YELLOW}App built but auto-launch failed. Open Simulator manually.${NC}"
        open -a Simulator
    fi
fi

echo ""
echo -e "${BLUE}Note: Grant microphone permission when prompted for full functionality.${NC}"
echo -e "${BLUE}The app works 100% offline — no internet required.${NC}"

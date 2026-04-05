#!/bin/bash

# Create a native macOS app bundle that works as a droplet
# This creates a proper .app that accepts drag-and-drop

APP_DIR="/Users/jack/Documents/Compress Images.app"
mkdir -p "$APP_DIR/Contents/MacOS"

# Create the executable
cat > "$APP_DIR/Contents/MacOS/Compress Images" << 'SCRIPTEOF'
#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if files were passed as arguments (drag & drop)
if [ $# -gt 0 ]; then
    for file in "$@"; do
        /Users/jack/Documents/GitHub/quick-compress/compress-images.sh "$file"
    done
    osascript -e 'display notification "Compression complete!" with title "Compress Images"'
else
    # No files - show file picker
    osascript << 'APPLESCRIPT'
        set chosenItems to choose file with multiple selections allowed with prompt "Select images or folders to compress:"
        repeat with anItem in chosenItems
            set itemPath to POSIX path of anItem
            do shell script "/Users/jack/Documents/GitHub/quick-compress/compress-images.sh " & quoted form of itemPath
        end repeat
        display notification "All images compressed!" with title "Compress Images"
APPLESCRIPT
fi
SCRIPTEOF

chmod +x "$APP_DIR/Contents/MacOS/Compress Images"

# Create Info.plist for drag-and-drop support
cat > "$APP_DIR/Contents/Info.plist" << 'PLISTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Compress Images</string>
    <key>CFBundleIdentifier</key>
    <string>com.jack.compressimages</string>
    <key>CFBundleName</key>
    <string>Compress Images</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.10</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>*</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>All Files</string>
            <key>CFBundleTypeOSTypes</key>
            <array>
                <string>****</string>
            </array>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
        </dict>
    </array>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024</string>
</dict>
</plist>
PLISTEOF

echo "Created: $APP_DIR"
echo ""
echo "HOW TO USE:"
echo "1. Double-click the app to open a file picker"
echo "2. OR drag files/folders onto the app icon"
echo ""
echo "TO ADD TO FINDER TOOLBAR:"
echo "1. Open Finder"
echo "2. Hold Command (⌘) and drag the app to the toolbar"
echo "3. Select files in Finder, then click the toolbar button"

#!/bin/bash

# Create a macOS Quick Action for Finder
# This script creates the Quick Action automatically

WORKFLOW_DIR="$HOME/Library/Services/Compress Images.workflow"
# Create the workflow directory structure
mkdir -p "$WORKFLOW_DIR/Contents"

# Create the Info.plist
cat > "$WORKFLOW_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>Compress Images for Web</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.image</string>
                <string>public.folder</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
EOF

# Create the Quick Action as an Automator workflow
cat > "$WORKFLOW_DIR/Contents/document.wflow" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>523</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <false/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Finder</string>
                </array>
                <key>AMParameterProperties</key>
                <dict>
                    <key>inputMethod</key>
                    <dict/>
                    <key>shell</key>
                    <dict/>
                    <key>source</key>
                    <dict/>
                </dict>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string>#!/bin/bash

for f in "\$@"; do
    /Users/jack/Documents/GitHub/quick-compress/compress-images.sh "\$f" &gt; /tmp/compress-output.log 2&gt;&amp;1
done

# Show notification
osascript -e 'display notification "Images optimized successfully!" with title "Compress Images"'</string>
                </dict>
                <key>ActionRuntimeParameters</key>
                <dict>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string>#!/bin/bash

for f in "\$@"; do
    /Users/jack/Documents/GitHub/quick-compress/compress-images.sh "\$f" &gt; /tmp/compress-output.log 2&gt;&amp;1
done

# Show notification
osascript -e 'display notification "Images optimized successfully!" with title "Compress Images"'</string>
                    <key>temporary items path</key>
                    <string>/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/com.apple.automator.Run-Shell-Script</string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <true/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>Category</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
                <key>InputUUID</key>
                <string>inputUUID</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>outputUUID</string>
                <key>ShowWhenRun</key>
                <false/>
                <key>UUID</key>
                <string>actionUUID</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Finder</string>
                </array>
                <key>arguments</key>
                <dict/>
                <key>isViewed</key>
                <true/>
                <key>source</key>
                <string>#!/bin/bash

for f in "\$@"; do
    /Users/jack/Documents/GitHub/quick-compress/compress-images.sh "\$f" &gt; /tmp/compress-output.log 2&gt;&amp;1
done

# Show notification
osascript -e 'display notification "Images optimized successfully!" with title "Compress Images"'</string>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>applicationBundleIDsByPath</key>
        <dict/>
        <key>applicationPaths</key>
        <array/>
        <key>inputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>outputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>presentationMode</key>
        <integer>15</integer>
        <key>processesInput</key>
        <integer>0</integer>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>serviceApplicationPath</key>
        <string>/System/Library/CoreServices/Finder.app</string>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>systemImageName</key>
        <string>NSActionTemplate</string>
        <key>useAutomaticInputType</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

echo "Quick Action installed!"
echo ""
echo "To use it:"
echo "1. Right-click any image or folder in Finder"
echo "2. Go to 'Quick Actions' → 'Compress Images for Web'"
echo ""
echo "Note: You may need to enable it in:"
echo "System Settings → Privacy & Security → Extensions → Added Extensions"

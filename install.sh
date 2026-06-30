#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="compress"
REPO_URL="https://github.com/jschof1/quick-compress"

# Print functions
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              Quick Compress Installer                      ║"
    echo "║          Optimize images for the web in seconds            ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Install ImageMagick
install_imagemagick() {
    local os
    os=$(detect_os)
    
    print_info "ImageMagick is required but not installed."
    
    if [[ "$os" == "macos" ]]; then
        if command_exists brew; then
            print_info "Installing ImageMagick via Homebrew..."
            brew install imagemagick
        else
            print_error "Homebrew not found. Please install Homebrew first:"
            print_info "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    elif [[ "$os" == "linux" ]]; then
        print_info "Installing ImageMagick..."
        if command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y imagemagick
        elif command_exists dnf; then
            sudo dnf install -y imagemagick
        elif command_exists yum; then
            sudo yum install -y imagemagick
        elif command_exists pacman; then
            sudo pacman -S imagemagick
        else
            print_error "Could not install ImageMagick automatically."
            print_info "Please install ImageMagick manually for your distribution."
            exit 1
        fi
    else
        print_error "Unsupported operating system. Please install ImageMagick manually."
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check for ImageMagick
    if ! command_exists magick && ! command_exists convert; then
        install_imagemagick
    fi
    
    print_success "ImageMagick is installed"
    
    # Create install directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        mkdir -p "$INSTALL_DIR"
        print_success "Created install directory: $INSTALL_DIR"
    fi
}

# Download and install the script
install_script() {
    print_info "Installing Quick Compress..."
    
    # Determine the script source
    if [[ -f "compress-images.sh" ]]; then
        # Local installation (for development)
        cp "compress-images.sh" "$INSTALL_DIR/$SCRIPT_NAME"
    else
        # Remote installation
        print_info "Downloading from GitHub..."
        curl -fsSL "$REPO_URL/raw/main/compress-images.sh" -o "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    # Make executable
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    print_success "Installed to $INSTALL_DIR/$SCRIPT_NAME"
}

# Add to PATH
add_to_path() {
    print_info "Checking PATH configuration..."
    
    # Determine shell
    local shell_rc
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Check if already in PATH
    if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        print_success "$INSTALL_DIR is already in PATH"
    else
        print_info "Adding $INSTALL_DIR to PATH in $shell_rc"
        {
            echo ""
            echo "# Added by Quick Compress installer"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\""
        } >> "$shell_rc"
        print_success "Added to PATH"
        print_warning "Please run: source $shell_rc"
    fi
}

# Install Finder integration (macOS only)
install_finder_integration() {
    local os
    os=$(detect_os)
    
    if [[ "$os" != "macos" ]]; then
        return 0
    fi
    
    print_info "Setting up Finder integration..."
    
    # Create the Quick Action
    local services_dir="$HOME/Library/Services"
    local workflow_dir="$services_dir/Compress Images.workflow"
    
    mkdir -p "$workflow_dir/Contents"
    
    # Create Info.plist for the Quick Action
    cat > "$workflow_dir/Contents/Info.plist" << 'EOF'
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

    # Create the workflow document
    cat > "$workflow_dir/Contents/document.wflow" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
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
                    <string>for f in "\$@"; do
    $INSTALL_DIR/$SCRIPT_NAME "\$f" &gt; /tmp/compress.log 2&gt;&amp;1
done
osascript -e 'display notification "Images optimized!" with title "Quick Compress"'</string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
            </dict>
        </dict>
    </array>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

    print_success "Finder Quick Action installed"
    print_info "Right-click files in Finder → Services → Compress Images for Web"
}

# Create uninstall script
create_uninstall_script() {
    cat > "$INSTALL_DIR/uninstall-quick-compress" << 'EOF'
#!/bin/bash
echo "Uninstalling Quick Compress..."
rm -f "$HOME/.local/bin/compress"
rm -f "$HOME/.local/bin/uninstall-quick-compress"
rm -rf "$HOME/Library/Services/Compress Images.workflow"
echo "Quick Compress has been uninstalled."
EOF
    chmod +x "$INSTALL_DIR/uninstall-quick-compress"
}

# Main installation
main() {
    print_header
    
    check_prerequisites
    install_script
    add_to_path
    install_finder_integration
    create_uninstall_script
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   Installation Complete!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_success "Quick Compress is now installed!"
    echo ""
    echo -e "${BLUE}Usage:${NC}"
    echo "  compress path/to/image.jpg    # Compress a single image"
    echo "  compress path/to/folder       # Compress all images in folder"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  compress ~/Downloads/photo.png"
    echo "  compress ~/Desktop/my-images/"
    echo ""
    
    if [[ $(detect_os) == "macos" ]]; then
        echo -e "${BLUE}Finder Integration:${NC}"
        echo "  Right-click any file or folder → Services → Compress Images for Web"
        echo ""
    fi
    
    echo -e "${BLUE}To uninstall:${NC}"
    echo "  uninstall-quick-compress"
    echo ""
    
    print_info "Please restart your terminal or run: source ~/.zshrc (or ~/.bashrc)"
}

# Run main function
main

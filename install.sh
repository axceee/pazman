#!/bin/bash

# pazman installer script
# Usage: curl -fsSL https://raw.githubusercontent.com/armancurr/cli-password/main/install.sh | bash

set -e  # Exit on any error

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect if running in PowerShell (wrong installer)
detect_shell() {
    if [ -n "$PSVersionTable" ] || [ -n "$PROMPT" ]; then
        print_message "$RED" "Error: This installer is for Bash/Zsh shells"
        echo ""
        print_message "$YELLOW" "You appear to be using PowerShell. Please use the PowerShell installer instead:"
        print_message "$CYAN" "  iwr -useb https://raw.githubusercontent.com/axceee/pazman/main/install.ps1 | iex"
        echo ""
        exit 1
    fi
}

# Configuration
REPO_URL="https://raw.githubusercontent.com/armancurr/cli-password/main"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="pazman"

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo ""
    print_message "$BLUE" "================================"
    print_message "$BLUE" "   pazman Password Manager"
    print_message "$BLUE" "   Secure CLI Installation"
    print_message "$BLUE" "================================"
    echo ""
    
    # Show detected environment
    local shell_name="Unknown"
    if [ -n "$BASH_VERSION" ]; then
        shell_name="Bash"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_name="Zsh"
    fi
    
    local os_name=$(uname -s 2>/dev/null || echo "Unknown")
    print_message "$CYAN" "Detected: $shell_name on $os_name"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_message "$YELLOW" "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check for required commands
    if ! command_exists openssl; then
        missing_deps+=("openssl")
    fi
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    # Check for clipboard utility (at least one should exist)
    local has_clipboard=false
    if command_exists clip.exe || command_exists pbcopy || command_exists xclip || command_exists wl-copy; then
        has_clipboard=true
    fi
    
    if [ "$has_clipboard" = false ]; then
        print_message "$YELLOW" "Warning: No clipboard utility found"
        print_message "$YELLOW" "Install xclip (Linux), wl-clipboard (Wayland), or use Git Bash on Windows"
    fi
    
    # Report missing dependencies
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_message "$RED" "Error: Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        print_message "$RED" "\nPlease install missing dependencies and try again."
        exit 1
    fi
    
    print_message "$GREEN" "✓ All prerequisites met"
}

# Create installation directory
create_install_dir() {
    if [ ! -d "$INSTALL_DIR" ]; then
        print_message "$YELLOW" "Creating installation directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
}

# Download pazman script
download_pazman() {
    print_message "$YELLOW" "Downloading pazman..."
    
    local temp_file=$(mktemp)
    
    if curl -fsSL "$REPO_URL/$SCRIPT_NAME" -o "$temp_file"; then
        mv "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        print_message "$GREEN" "✓ pazman downloaded successfully"
    else
        print_message "$RED" "Error: Failed to download pazman"
        rm -f "$temp_file"
        exit 1
    fi
}

# Check if directory is in PATH
is_in_path() {
    local dir=$1
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Add to PATH instructions
setup_path() {
    if ! is_in_path "$INSTALL_DIR"; then
        print_message "$YELLOW" "\n  Installation directory is not in your PATH"
        print_message "$YELLOW" "Add the following line to your shell configuration file:\n"
        
        # Detect shell and give appropriate instructions
        local shell_config=""
        if [ -n "$BASH_VERSION" ]; then
            if [ "$(uname)" = "Darwin" ]; then
                shell_config="$HOME/.bash_profile"
            else
                shell_config="$HOME/.bashrc"
            fi
        elif [ -n "$ZSH_VERSION" ]; then
            shell_config="$HOME/.zshrc"
        else
            shell_config="$HOME/.profile"
        fi
        
        print_message "$BLUE" "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        print_message "$YELLOW" "Then run: source $shell_config"
        print_message "$YELLOW" "Or simply restart your terminal"
    else
        print_message "$GREEN" "✓ Installation directory is already in PATH"
    fi
}

# Test installation
test_installation() {
    print_message "$YELLOW" "\nTesting installation..."
    
    if is_in_path "$INSTALL_DIR" && command_exists pazman; then
        print_message "$GREEN" "✓ pazman is ready to use!"
        echo ""
        print_message "$BLUE" "Run 'pazman help' to get started"
    else
        print_message "$YELLOW" "Installation complete, but you need to update your PATH first"
    fi
}

# Print success message
print_success() {
    echo ""
    print_message "$GREEN" "================================"
    print_message "$GREEN" "   Installation Complete!   "
    print_message "$GREEN" "================================"
    echo ""
    print_message "$BLUE" "Quick start:"
    echo "  1. Run: pazman set github"
    echo "  2. Create your master password"
    echo "  3. Your password is generated and copied!"
    echo ""
    print_message "$BLUE" "Documentation:"
    echo "  https://github.com/armancurr/cli-password"
    echo ""
}

# Uninstall function
uninstall_pazman() {
    print_message "$YELLOW" "Uninstalling pazman..."
    
    # Remove script
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        rm "$INSTALL_DIR/$SCRIPT_NAME"
        print_message "$GREEN" "✓ Removed pazman script"
    fi
    
    # Ask about data
    read -p "Remove stored passwords (~/.pazman)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$HOME/.pazman"
        print_message "$GREEN" "✓ Removed password data"
    fi
    
    print_message "$GREEN" "Uninstallation complete"
}

# Main installation flow
main() {
    # Check if uninstall flag is passed
    if [ "$1" = "--uninstall" ]; then
        uninstall_pazman
        exit 0
    fi
    
    # Detect shell environment
    detect_shell
    
    print_header
    check_prerequisites
    create_install_dir
    download_pazman
    setup_path
    test_installation
    print_success
}

# Run main function
main "$@"

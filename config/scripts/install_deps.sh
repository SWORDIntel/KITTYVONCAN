#!/bin/bash
# KITTYVONCAN Dependency Installation Script
# Installs all required dependencies for optimal functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
FONTS_ONLY=false
SKIP_FONTS=false
DRY_RUN=false

# Package manager detection
PM_CMD=""
PM_UPDATE=""
PM_INSTALL=""

# Print functions
print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Show help
show_help() {
    cat << EOF
KITTYVONCAN Dependency Installation Script

USAGE:
    ./install_deps.sh [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -d, --dry-run       Show what would be installed without making changes
    --fonts-only        Install only fonts
    --skip-fonts        Skip font installation
    --update-cache      Update package manager cache before installing

DEPENDENCIES INSTALLED:
    Essential:
    - xclip             Clipboard operations
    - xdotool           Keyboard automation
    - zenity            Dialog boxes

    Optional:
    - rofi              Enhanced menu system (fallback: zenity)
    - curl/wget         Font downloads
    - unzip             Font extraction

    Fonts:
    - JetBrains Mono    Professional development font with ligatures

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --fonts-only)
                FONTS_ONLY=true
                shift
                ;;
            --skip-fonts)
                SKIP_FONTS=true
                shift
                ;;
            --update-cache)
                UPDATE_CACHE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Detect package manager
detect_package_manager() {
    print_step "Detecting package manager..."

    if command -v apt-get &> /dev/null; then
        PM_CMD="apt-get"
        PM_UPDATE="sudo apt-get update"
        PM_INSTALL="sudo apt-get install -y"
        print_success "Detected: APT (Debian/Ubuntu)"
    elif command -v dnf &> /dev/null; then
        PM_CMD="dnf"
        PM_UPDATE="sudo dnf makecache"
        PM_INSTALL="sudo dnf install -y"
        print_success "Detected: DNF (Fedora/RHEL)"
    elif command -v yum &> /dev/null; then
        PM_CMD="yum"
        PM_UPDATE="sudo yum makecache"
        PM_INSTALL="sudo yum install -y"
        print_success "Detected: YUM (CentOS/RHEL)"
    elif command -v pacman &> /dev/null; then
        PM_CMD="pacman"
        PM_UPDATE="sudo pacman -Sy"
        PM_INSTALL="sudo pacman -S --noconfirm"
        print_success "Detected: Pacman (Arch Linux)"
    elif command -v zypper &> /dev/null; then
        PM_CMD="zypper"
        PM_UPDATE="sudo zypper refresh"
        PM_INSTALL="sudo zypper install -y"
        print_success "Detected: Zypper (openSUSE)"
    elif command -v apk &> /dev/null; then
        PM_CMD="apk"
        PM_UPDATE="sudo apk update"
        PM_INSTALL="sudo apk add"
        print_success "Detected: APK (Alpine Linux)"
    else
        print_error "No supported package manager found"
        print_info "Supported: apt-get, dnf, yum, pacman, zypper, apk"
        exit 1
    fi
}

# Update package cache
update_package_cache() {
    if [[ "${UPDATE_CACHE:-false}" == "true" ]]; then
        print_step "Updating package cache..."

        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "Would run: $PM_UPDATE"
            return 0
        fi

        if eval "$PM_UPDATE"; then
            print_success "Package cache updated"
        else
            print_warning "Failed to update package cache"
        fi
    fi
}

# Install essential dependencies
install_essential_deps() {
    if [[ "$FONTS_ONLY" == "true" ]]; then
        return 0
    fi

    print_step "Installing essential dependencies..."

    local deps=()

    # Map dependencies to different package managers
    case "$PM_CMD" in
        "apt-get")
            deps=("xclip" "xdotool" "zenity")
            ;;
        "dnf"|"yum")
            deps=("xclip" "xdotool" "zenity")
            ;;
        "pacman")
            deps=("xclip" "xdotool" "zenity")
            ;;
        "zypper")
            deps=("xclip" "xdotool" "zenity")
            ;;
        "apk")
            deps=("xclip" "xdotool" "zenity")
            ;;
    esac

    # Check which dependencies are missing
    local missing_deps=()
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" &> /dev/null; then
            missing_deps+=("$dep")
        else
            print_success "$dep already installed"
        fi
    done

    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        print_success "All essential dependencies already installed"
        return 0
    fi

    print_info "Missing dependencies: ${missing_deps[*]}"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would install: ${missing_deps[*]}"
        return 0
    fi

    # Install missing dependencies
    if eval "$PM_INSTALL ${missing_deps[*]}"; then
        print_success "Essential dependencies installed"
    else
        print_error "Failed to install some dependencies"
        exit 1
    fi
}

# Install optional dependencies
install_optional_deps() {
    if [[ "$FONTS_ONLY" == "true" ]]; then
        return 0
    fi

    print_step "Installing optional dependencies..."

    local optional_deps=()

    # Map optional dependencies
    case "$PM_CMD" in
        "apt-get")
            optional_deps=("rofi" "curl" "unzip")
            ;;
        "dnf"|"yum")
            optional_deps=("rofi" "curl" "unzip")
            ;;
        "pacman")
            optional_deps=("rofi" "curl" "unzip")
            ;;
        "zypper")
            optional_deps=("rofi" "curl" "unzip")
            ;;
        "apk")
            optional_deps=("rofi" "curl" "unzip")
            ;;
    esac

    for dep in "${optional_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep already installed"
        else
            print_info "Installing optional dependency: $dep"

            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "Would install: $dep"
                continue
            fi

            if eval "$PM_INSTALL $dep"; then
                print_success "$dep installed"
            else
                print_warning "Failed to install $dep (optional)"
            fi
        fi
    done
}

# Install JetBrains Mono font
install_jetbrains_mono() {
    if [[ "$SKIP_FONTS" == "true" ]]; then
        return 0
    fi

    print_step "Installing JetBrains Mono font..."

    # Check if already installed
    if fc-list | grep -i "jetbrains mono" &> /dev/null; then
        print_success "JetBrains Mono already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would download and install JetBrains Mono font"
        return 0
    fi

    # Create font directory
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # Download JetBrains Mono
    print_info "Downloading JetBrains Mono..."

    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip"

    # Use curl or wget
    if command -v curl &> /dev/null; then
        if curl -L "$font_url" -o "$temp_dir/JetBrainsMono.zip"; then
            print_success "Font downloaded with curl"
        else
            print_error "Failed to download font with curl"
            rm -rf "$temp_dir"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        if wget "$font_url" -O "$temp_dir/JetBrainsMono.zip"; then
            print_success "Font downloaded with wget"
        else
            print_error "Failed to download font with wget"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_error "Neither curl nor wget found - cannot download font"
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract font
    print_info "Extracting font files..."

    cd "$temp_dir"
    if unzip -q JetBrainsMono.zip; then
        print_success "Font archive extracted"
    else
        print_error "Failed to extract font archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install font files
    if [[ -d "fonts/ttf" ]]; then
        cp fonts/ttf/*.ttf "$font_dir/"
        print_success "Font files copied to $font_dir"
    else
        print_error "Font files not found in expected location"
        rm -rf "$temp_dir"
        return 1
    fi

    # Update font cache
    print_info "Updating font cache..."
    if fc-cache -f; then
        print_success "Font cache updated"
    else
        print_warning "Failed to update font cache"
    fi

    # Cleanup
    rm -rf "$temp_dir"

    # Verify installation
    if fc-list | grep -i "jetbrains mono" &> /dev/null; then
        print_success "JetBrains Mono installation verified"
    else
        print_warning "JetBrains Mono installation could not be verified"
    fi
}

# Install development tools (optional)
install_dev_tools() {
    if [[ "$FONTS_ONLY" == "true" ]]; then
        return 0
    fi

    print_step "Checking development tools..."

    local dev_tools=("nvim" "vim" "ranger" "htop")

    for tool in "${dev_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_success "$tool found"
        else
            print_info "$tool not found (F-key shortcuts may not work fully)"

            if [[ "$DRY_RUN" == "false" ]]; then
                read -p "Install $tool? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if eval "$PM_INSTALL $tool"; then
                        print_success "$tool installed"
                    else
                        print_warning "Failed to install $tool"
                    fi
                fi
            else
                print_info "Would offer to install $tool"
            fi
        fi
    done
}

# Validate installation
validate_installation() {
    print_step "Validating dependency installation..."

    local essential_deps=("xclip" "xdotool" "zenity")
    local missing_essential=()

    for dep in "${essential_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_success "$dep verified"
        else
            missing_essential+=("$dep")
            print_error "$dep missing"
        fi
    done

    # Check font
    if [[ "$SKIP_FONTS" == "false" ]]; then
        if fc-list | grep -i "jetbrains mono" &> /dev/null; then
            print_success "JetBrains Mono font verified"
        else
            print_warning "JetBrains Mono font not found"
        fi
    fi

    if [[ ${#missing_essential[@]} -eq 0 ]]; then
        print_success "All essential dependencies verified"
        return 0
    else
        print_error "Missing essential dependencies: ${missing_essential[*]}"
        return 1
    fi
}

# Print summary
print_summary() {
    echo
    echo -e "${CYAN}━━━ DEPENDENCY INSTALLATION SUMMARY ━━━${NC}"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}DRY RUN - No packages were actually installed${NC}"
    else
        echo -e "${GREEN}Installation completed${NC}"
    fi

    echo
    echo -e "${CYAN}Installed components:${NC}"
    echo "• Essential tools: xclip, xdotool, zenity"
    echo "• Optional tools: rofi (if available)"

    if [[ "$SKIP_FONTS" == "false" ]]; then
        echo "• JetBrains Mono font"
    fi

    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo "• Run KITTYVONCAN installation: ./install.sh"
    echo "• Test features: ./tests/test_features.sh"
    echo "• Validate config: ./tests/validate_config.sh"
}

# Main function
main() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║        KITTYVONCAN DEPENDENCY INSTALLER 📦        ║"
    echo "║          Essential Tools & Font Setup            ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"

    parse_args "$@"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN MODE - No packages will be installed"
        echo
    fi

    detect_package_manager
    update_package_cache

    if [[ "$FONTS_ONLY" == "false" ]]; then
        install_essential_deps
        install_optional_deps
        install_dev_tools
    fi

    install_jetbrains_mono

    if [[ "$DRY_RUN" == "false" ]]; then
        validate_installation
    fi

    print_summary
}

# Run main function
main "$@"
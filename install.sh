#!/bin/bash
# KITTYVONCAN Installation Script
# Professional Kitty Terminal Enhancement Package
# Version: 1.0.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KITTY_CONFIG_DIR="$HOME/.config/kitty"
BACKUP_DIR="$KITTY_CONFIG_DIR/backups/kittyvoncan-$(date +%Y%m%d-%H%M%S)"
KITTYVONCAN_DIR="$KITTY_CONFIG_DIR/kittyvoncan"

# Installation options
DRY_RUN=false
MINIMAL_INSTALL=false
BACKUP_ONLY=false
RESTORE_MODE=false
FORCE_INSTALL=false
SKIP_DEPS=false

# Print functions
print_header() {
    echo -e "${PURPLE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║           KITTYVONCAN 🐱              ║"
    echo "  ║   Professional Kitty Enhancement      ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

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

# Help function
show_help() {
    cat << EOF
KITTYVONCAN Installation Script

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -d, --dry-run       Show what would be installed without making changes
    -m, --minimal       Install minimal configuration only
    -f, --full          Install all features (default)
    -b, --backup-only   Only backup existing configuration
    -r, --restore       Restore from most recent backup
    --force             Force installation even if kitty not found
    --skip-deps         Skip dependency installation
    --purge             Remove all KITTYVONCAN files and restore original

EXAMPLES:
    ./install.sh                    # Full installation
    ./install.sh --dry-run          # Preview changes
    ./install.sh --minimal          # Core features only
    ./install.sh --backup-only      # Backup current config
    ./install.sh --restore          # Restore from backup

EOF
}

# Parse command line arguments
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
            -m|--minimal)
                MINIMAL_INSTALL=true
                shift
                ;;
            -f|--full)
                MINIMAL_INSTALL=false
                shift
                ;;
            -b|--backup-only)
                BACKUP_ONLY=true
                shift
                ;;
            -r|--restore)
                RESTORE_MODE=true
                shift
                ;;
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --purge)
                purge_installation
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if kitty is installed
check_kitty() {
    if ! command -v kitty &> /dev/null; then
        if [[ "$FORCE_INSTALL" == "false" ]]; then
            print_error "Kitty terminal not found. Install kitty first or use --force"
            print_info "Install kitty: https://sw.kovidgoyal.net/kitty/binary/"
            exit 1
        else
            print_warning "Kitty not found, but continuing due to --force flag"
        fi
    else
        local kitty_version=$(kitty --version | cut -d' ' -f2)
        print_success "Found kitty version $kitty_version"
    fi
}

# Check and install dependencies
check_dependencies() {
    if [[ "$SKIP_DEPS" == "true" ]]; then
        print_info "Skipping dependency check"
        return 0
    fi

    print_step "Checking dependencies..."

    local missing_deps=()
    local deps=("xclip" "xdotool" "zenity")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"

        if [[ "$DRY_RUN" == "false" ]]; then
            print_step "Installing missing dependencies..."

            # Detect package manager and install
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y "${missing_deps[@]}"
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm "${missing_deps[@]}"
            elif command -v zypper &> /dev/null; then
                sudo zypper install -y "${missing_deps[@]}"
            else
                print_error "Could not detect package manager. Please install manually: ${missing_deps[*]}"
                exit 1
            fi

            print_success "Dependencies installed"
        fi
    else
        print_success "All dependencies found"
    fi
}

# Backup existing configuration
backup_config() {
    print_step "Creating backup..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would create backup at: $BACKUP_DIR"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"

    if [[ -f "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
        cp "$KITTY_CONFIG_DIR/kitty.conf" "$BACKUP_DIR/"
        print_success "Backed up kitty.conf"
    fi

    if [[ -d "$KITTY_CONFIG_DIR/scripts" ]]; then
        cp -r "$KITTY_CONFIG_DIR/scripts" "$BACKUP_DIR/"
        print_success "Backed up scripts directory"
    fi

    if [[ -d "$KITTY_CONFIG_DIR/themes" ]]; then
        cp -r "$KITTY_CONFIG_DIR/themes" "$BACKUP_DIR/"
        print_success "Backed up themes directory"
    fi

    echo "$BACKUP_DIR" > "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup"
    print_success "Backup created at: $BACKUP_DIR"
}

# Install fonts
install_fonts() {
    if [[ "$MINIMAL_INSTALL" == "true" ]]; then
        print_info "Skipping font installation in minimal mode"
        return 0
    fi

    print_step "Installing JetBrains Mono font..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would install JetBrains Mono font"
        return 0
    fi

    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    # Check if JetBrains Mono is already installed
    if fc-list | grep -i "jetbrains mono" &> /dev/null; then
        print_success "JetBrains Mono already installed"
        return 0
    fi

    # Download and install JetBrains Mono
    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip"

    if command -v curl &> /dev/null; then
        curl -L "$font_url" -o "$temp_dir/JetBrainsMono.zip"
    elif command -v wget &> /dev/null; then
        wget "$font_url" -O "$temp_dir/JetBrainsMono.zip"
    else
        print_warning "Could not download font. Please install curl or wget"
        return 1
    fi

    cd "$temp_dir"
    unzip -q JetBrainsMono.zip
    cp fonts/ttf/*.ttf "$font_dir/"

    # Update font cache
    fc-cache -f

    rm -rf "$temp_dir"
    print_success "JetBrains Mono font installed"
}

# Install configuration files
install_config() {
    print_step "Installing configuration files..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would install configuration files to $KITTY_CONFIG_DIR"
        return 0
    fi

    # Create directories
    mkdir -p "$KITTY_CONFIG_DIR"/{scripts,themes}
    mkdir -p "$KITTYVONCAN_DIR"

    # Copy main configuration
    cp "$SCRIPT_DIR/config/kitty.conf" "$KITTY_CONFIG_DIR/"
    print_success "Installed main configuration"

    # Copy scripts
    cp -r "$SCRIPT_DIR/config/scripts/"* "$KITTY_CONFIG_DIR/scripts/"
    chmod +x "$KITTY_CONFIG_DIR/scripts/"*.sh
    print_success "Installed scripts"

    # Copy themes
    cp -r "$SCRIPT_DIR/themes/"* "$KITTY_CONFIG_DIR/themes/"
    print_success "Installed themes"

    # Create custom configuration file
    if [[ ! -f "$KITTYVONCAN_DIR/custom.conf" ]]; then
        cat > "$KITTYVONCAN_DIR/custom.conf" << EOF
# KITTYVONCAN Custom Configuration
# Add your personal kitty settings here
# These settings will be preserved during updates

# Example custom settings:
# font_size 14.0
# background_opacity 0.9
# Remember to reload config after changes: kitty @ load-config
EOF
        print_success "Created custom configuration template"
    fi
}

# Restore from backup
restore_backup() {
    print_step "Restoring from backup..."

    local last_backup
    if [[ -f "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup" ]]; then
        last_backup=$(cat "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup")
    else
        print_error "No backup found to restore from"
        exit 1
    fi

    if [[ ! -d "$last_backup" ]]; then
        print_error "Backup directory not found: $last_backup"
        exit 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would restore from: $last_backup"
        return 0
    fi

    # Restore files
    if [[ -f "$last_backup/kitty.conf" ]]; then
        cp "$last_backup/kitty.conf" "$KITTY_CONFIG_DIR/"
        print_success "Restored kitty.conf"
    fi

    if [[ -d "$last_backup/scripts" ]]; then
        rm -rf "$KITTY_CONFIG_DIR/scripts"
        cp -r "$last_backup/scripts" "$KITTY_CONFIG_DIR/"
        print_success "Restored scripts"
    fi

    if [[ -d "$last_backup/themes" ]]; then
        rm -rf "$KITTY_CONFIG_DIR/themes"
        cp -r "$last_backup/themes" "$KITTY_CONFIG_DIR/"
        print_success "Restored themes"
    fi

    print_success "Configuration restored from backup"
}

# Purge installation
purge_installation() {
    print_step "Purging KITTYVONCAN installation..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would remove all KITTYVONCAN files"
        return 0
    fi

    # Remove KITTYVONCAN directory
    if [[ -d "$KITTYVONCAN_DIR" ]]; then
        rm -rf "$KITTYVONCAN_DIR"
        print_success "Removed KITTYVONCAN directory"
    fi

    # Remove backup marker
    if [[ -f "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup" ]]; then
        rm "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup"
        print_success "Removed backup marker"
    fi

    print_warning "Note: Original configuration files were preserved"
    print_info "To restore original config, use: ./install.sh --restore"
}

# Validate installation
validate_installation() {
    print_step "Validating installation..."

    local errors=0

    # Check kitty.conf
    if [[ ! -f "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
        print_error "kitty.conf not found"
        ((errors++))
    fi

    # Check context menu script
    if [[ ! -f "$KITTY_CONFIG_DIR/scripts/context_menu.sh" ]]; then
        print_error "Context menu script not found"
        ((errors++))
    elif [[ ! -x "$KITTY_CONFIG_DIR/scripts/context_menu.sh" ]]; then
        print_error "Context menu script not executable"
        ((errors++))
    fi

    # Test kitty configuration
    if command -v kitty &> /dev/null; then
        if ! kitty --config="$KITTY_CONFIG_DIR/kitty.conf" --debug-config 2>/dev/null; then
            print_error "Kitty configuration validation failed"
            ((errors++))
        fi
    fi

    if [[ $errors -eq 0 ]]; then
        print_success "Installation validation passed"
        return 0
    else
        print_error "Installation validation failed with $errors error(s)"
        return 1
    fi
}

# Print completion message
print_completion() {
    echo
    echo -e "${GREEN}🎉 KITTYVONCAN installation completed successfully!${NC}"
    echo
    echo -e "${CYAN}Quick Start:${NC}"
    echo "  • Right-click in terminal for context menu"
    echo "  • Press F1-F12 for development shortcuts"
    echo "  • Ctrl+Shift+M for manual context menu"
    echo "  • Ctrl+Alt+S for new session"
    echo
    echo -e "${CYAN}Configuration:${NC}"
    echo "  • Main config: $KITTY_CONFIG_DIR/kitty.conf"
    echo "  • Custom config: $KITTYVONCAN_DIR/custom.conf"
    echo "  • Scripts: $KITTY_CONFIG_DIR/scripts/"
    echo
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  • Restart kitty or press F5 to reload config"
    echo "  • Run ./tests/test_features.sh to verify features"
    echo "  • Edit custom.conf for personal settings"
    echo
    if [[ -f "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup" ]]; then
        local backup_path=$(cat "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup")
        echo -e "${YELLOW}Backup created:${NC} $backup_path"
    fi
}

# Main installation function
main() {
    print_header

    parse_args "$@"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN MODE - No changes will be made"
        echo
    fi

    # Handle special modes
    if [[ "$RESTORE_MODE" == "true" ]]; then
        restore_backup
        print_success "Restore completed"
        exit 0
    fi

    if [[ "$BACKUP_ONLY" == "true" ]]; then
        check_kitty
        backup_config
        print_success "Backup completed"
        exit 0
    fi

    # Regular installation
    check_kitty
    check_dependencies
    backup_config

    if [[ "$MINIMAL_INSTALL" == "false" ]]; then
        install_fonts
    fi

    install_config

    if [[ "$DRY_RUN" == "false" ]]; then
        validate_installation
        print_completion
    else
        print_info "Dry run completed - no changes were made"
    fi
}

# Run main function with all arguments
main "$@"
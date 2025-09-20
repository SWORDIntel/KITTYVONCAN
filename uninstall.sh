#!/bin/bash
# KITTYVONCAN Uninstallation Script
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
KITTY_CONFIG_DIR="$HOME/.config/kitty"
KITTYVONCAN_DIR="$KITTY_CONFIG_DIR/kittyvoncan"

# Uninstallation options
DRY_RUN=false
PURGE_ALL=false
RESTORE_ORIGINAL=false
KEEP_BACKUP=true

# Print functions
print_header() {
    echo -e "${PURPLE}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║     KITTYVONCAN UNINSTALLER 🗑️        ║"
    echo "  ║   Remove Professional Enhancements    ║"
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
KITTYVONCAN Uninstallation Script

USAGE:
    ./uninstall.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -d, --dry-run           Show what would be removed without making changes
    --purge                 Remove all KITTYVONCAN files including backups
    --restore-original      Restore original kitty configuration from backup
    --keep-custom           Keep custom configuration file
    --remove-fonts          Also remove JetBrains Mono fonts

EXAMPLES:
    ./uninstall.sh                      # Standard uninstall (keeps backups)
    ./uninstall.sh --dry-run            # Preview what will be removed
    ./uninstall.sh --purge              # Remove everything including backups
    ./uninstall.sh --restore-original   # Restore pre-installation config

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
            --purge)
                PURGE_ALL=true
                KEEP_BACKUP=false
                shift
                ;;
            --restore-original)
                RESTORE_ORIGINAL=true
                shift
                ;;
            --keep-custom)
                # This option preserved for compatibility
                shift
                ;;
            --remove-fonts)
                # TODO: Implement font removal
                print_warning "Font removal not implemented yet"
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

# Check if KITTYVONCAN is installed
check_installation() {
    if [[ ! -d "$KITTY_CONFIG_DIR" ]]; then
        print_error "Kitty configuration directory not found"
        exit 1
    fi

    if [[ ! -f "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup" ]] && [[ ! -d "$KITTYVONCAN_DIR" ]]; then
        print_warning "KITTYVONCAN installation not detected"
        print_info "This might not be a KITTYVONCAN-managed kitty installation"

        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Restore original configuration
restore_original() {
    print_step "Restoring original configuration..."

    local backup_file="$KITTY_CONFIG_DIR/.kittyvoncan_last_backup"

    if [[ ! -f "$backup_file" ]]; then
        print_error "No backup information found"
        return 1
    fi

    local backup_dir=$(cat "$backup_file")

    if [[ ! -d "$backup_dir" ]]; then
        print_error "Backup directory not found: $backup_dir"
        return 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would restore configuration from: $backup_dir"
        return 0
    fi

    # Restore kitty.conf
    if [[ -f "$backup_dir/kitty.conf" ]]; then
        cp "$backup_dir/kitty.conf" "$KITTY_CONFIG_DIR/"
        print_success "Restored original kitty.conf"
    else
        print_warning "Original kitty.conf not found in backup"
        # Create minimal config
        cat > "$KITTY_CONFIG_DIR/kitty.conf" << EOF
# Minimal kitty configuration
# KITTYVONCAN has been uninstalled

font_family monospace
font_size 12.0
EOF
        print_info "Created minimal kitty.conf"
    fi

    # Restore scripts if they existed
    if [[ -d "$backup_dir/scripts" ]]; then
        rm -rf "$KITTY_CONFIG_DIR/scripts"
        cp -r "$backup_dir/scripts" "$KITTY_CONFIG_DIR/"
        print_success "Restored original scripts"
    fi

    # Restore themes if they existed
    if [[ -d "$backup_dir/themes" ]]; then
        rm -rf "$KITTY_CONFIG_DIR/themes"
        cp -r "$backup_dir/themes" "$KITTY_CONFIG_DIR/"
        print_success "Restored original themes"
    fi

    print_success "Original configuration restored"
}

# Remove KITTYVONCAN files
remove_kittyvoncan_files() {
    print_step "Removing KITTYVONCAN files..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would remove KITTYVONCAN directory: $KITTYVONCAN_DIR"
        if [[ -f "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
            print_info "Would reset kitty.conf to minimal configuration"
        fi
        return 0
    fi

    # Remove KITTYVONCAN directory
    if [[ -d "$KITTYVONCAN_DIR" ]]; then
        rm -rf "$KITTYVONCAN_DIR"
        print_success "Removed KITTYVONCAN directory"
    fi

    # Check if we should restore original or create minimal config
    if [[ "$RESTORE_ORIGINAL" == "true" ]]; then
        restore_original
    else
        # Create a minimal kitty.conf
        cat > "$KITTY_CONFIG_DIR/kitty.conf" << EOF
# Minimal kitty configuration
# KITTYVONCAN has been uninstalled
# To reinstall: https://github.com/YOUR_USERNAME/kittyvoncan

font_family monospace
font_size 12.0

# Basic settings
scrollback_lines 2000
enable_audio_bell no
remember_window_size yes
window_padding_width 4

# Basic shortcuts
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+t new_tab
map ctrl+shift+w close_tab
map ctrl+shift+enter new_window
EOF
        print_success "Created minimal kitty configuration"
    fi
}

# Remove backups
remove_backups() {
    if [[ "$KEEP_BACKUP" == "true" ]]; then
        print_info "Keeping backup files (use --purge to remove)"
        return 0
    fi

    print_step "Removing backup files..."

    local backup_file="$KITTY_CONFIG_DIR/.kittyvoncan_last_backup"

    if [[ -f "$backup_file" ]]; then
        local backup_dir=$(cat "$backup_file")

        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "Would remove backup: $backup_dir"
            print_info "Would remove backup marker: $backup_file"
            return 0
        fi

        if [[ -d "$backup_dir" ]]; then
            rm -rf "$backup_dir"
            print_success "Removed backup directory: $backup_dir"
        fi

        rm -f "$backup_file"
        print_success "Removed backup marker"
    fi

    # Remove any other KITTYVONCAN backups
    local backup_pattern="$KITTY_CONFIG_DIR/backups/kittyvoncan-*"
    if compgen -G "$backup_pattern" > /dev/null 2>&1; then
        if [[ "$DRY_RUN" == "false" ]]; then
            rm -rf $backup_pattern
            print_success "Removed additional KITTYVONCAN backups"
        else
            print_info "Would remove additional backups: $backup_pattern"
        fi
    fi
}

# Remove KITTYVONCAN-specific scripts and themes
remove_enhancements() {
    print_step "Removing KITTYVONCAN enhancements..."

    local files_to_remove=(
        "$KITTY_CONFIG_DIR/scripts/context_menu.sh"
        "$KITTY_CONFIG_DIR/scripts/context_menu_simple.sh"
        "$KITTY_CONFIG_DIR/scripts/test_menu.sh"
        "$KITTY_CONFIG_DIR/scripts/check_menu_status.sh"
        "$KITTY_CONFIG_DIR/themes/nord.conf"
    )

    for file in "${files_to_remove[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "Would remove: $file"
            else
                rm -f "$file"
                print_success "Removed: $(basename "$file")"
            fi
        fi
    done

    # Clean up empty directories
    if [[ "$DRY_RUN" == "false" ]]; then
        if [[ -d "$KITTY_CONFIG_DIR/scripts" ]] && [[ -z "$(ls -A "$KITTY_CONFIG_DIR/scripts")" ]]; then
            rmdir "$KITTY_CONFIG_DIR/scripts"
            print_success "Removed empty scripts directory"
        fi

        if [[ -d "$KITTY_CONFIG_DIR/themes" ]] && [[ -z "$(ls -A "$KITTY_CONFIG_DIR/themes")" ]]; then
            rmdir "$KITTY_CONFIG_DIR/themes"
            print_success "Removed empty themes directory"
        fi
    fi
}

# Validate uninstallation
validate_uninstallation() {
    print_step "Validating uninstallation..."

    local issues=0

    # Check that KITTYVONCAN directory is gone
    if [[ -d "$KITTYVONCAN_DIR" ]]; then
        print_warning "KITTYVONCAN directory still exists"
        ((issues++))
    fi

    # Check that kitty.conf exists and is valid
    if [[ ! -f "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
        print_error "kitty.conf not found after uninstallation"
        ((issues++))
    elif command -v kitty &> /dev/null; then
        if ! kitty --config="$KITTY_CONFIG_DIR/kitty.conf" --debug-config &>/dev/null; then
            print_warning "kitty.conf may have syntax issues"
            ((issues++))
        fi
    fi

    if [[ $issues -eq 0 ]]; then
        print_success "Uninstallation validation passed"
        return 0
    else
        print_warning "Uninstallation completed with $issues issue(s)"
        return 1
    fi
}

# Print completion message
print_completion() {
    echo
    echo -e "${GREEN}🗑️ KITTYVONCAN uninstallation completed!${NC}"
    echo

    if [[ "$RESTORE_ORIGINAL" == "true" ]]; then
        echo -e "${CYAN}✓ Original configuration restored${NC}"
    else
        echo -e "${CYAN}✓ Minimal configuration created${NC}"
    fi

    if [[ "$KEEP_BACKUP" == "true" ]]; then
        echo -e "${CYAN}✓ Backup files preserved${NC}"
        if [[ -f "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup" ]]; then
            local backup_path=$(cat "$KITTY_CONFIG_DIR/.kittyvoncan_last_backup")
            echo -e "${YELLOW}Backup location:${NC} $backup_path"
        fi
    else
        echo -e "${CYAN}✓ All backup files removed${NC}"
    fi

    echo
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  • Restart kitty to apply changes"
    echo "  • Check kitty.conf if you have custom settings"
    echo "  • Reinstall anytime from: https://github.com/YOUR_USERNAME/kittyvoncan"
    echo
    echo -e "${YELLOW}Thank you for trying KITTYVONCAN! 🐱${NC}"
}

# Main uninstallation function
main() {
    print_header

    parse_args "$@"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN MODE - No changes will be made"
        echo
    fi

    check_installation

    # Confirm uninstallation unless in dry run mode
    if [[ "$DRY_RUN" == "false" ]]; then
        echo -e "${YELLOW}This will uninstall KITTYVONCAN from your system.${NC}"
        if [[ "$PURGE_ALL" == "true" ]]; then
            echo -e "${RED}WARNING: --purge will remove ALL backups permanently!${NC}"
        fi
        echo
        read -p "Continue with uninstallation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Uninstallation cancelled"
            exit 0
        fi
    fi

    remove_kittyvoncan_files
    remove_enhancements

    if [[ "$PURGE_ALL" == "true" ]]; then
        remove_backups
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        validate_uninstallation
        print_completion
    else
        print_info "Dry run completed - no changes were made"
    fi
}

# Run main function with all arguments
main "$@"
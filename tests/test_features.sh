#!/bin/bash
# KITTYVONCAN Feature Testing Script
# Interactive testing of all KITTYVONCAN features

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
KITTY_CONFIG_DIR="$HOME/.config/kitty"
TEST_MODE="interactive"

# Print functions
print_header() {
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║           KITTYVONCAN FEATURE TESTER 🚀           ║"
    echo "║         Interactive Feature Validation           ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

print_test() {
    echo -e "${BLUE}🧪${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Wait for user input
wait_for_user() {
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Test function keys
test_function_keys() {
    print_section "Testing F-Key Development Shortcuts"

    cat << EOF
${CYAN}The following F-keys should be configured:${NC}

${BLUE}F1${NC}  - Launch Neovim in current directory
${BLUE}F2${NC}  - Open Ranger file manager
${BLUE}F3${NC}  - Launch htop system monitor
${BLUE}F4${NC}  - New window with current working directory
${BLUE}F5${NC}  - Reload kitty configuration
${BLUE}F6${NC}  - Debug configuration
${BLUE}F7${NC}  - Git status overlay
${BLUE}F8${NC}  - New tab with current working directory
${BLUE}F9${NC}  - Tail Claude logs
${BLUE}F10${NC} - Toggle fullscreen
${BLUE}F11${NC} - Toggle maximized
${BLUE}F12${NC} - Quick shell overlay

${YELLOW}Test Instructions:${NC}
1. Open a new kitty window
2. Try pressing each F-key to verify functionality
3. Check that F5 reloads the configuration without errors

EOF

    wait_for_user

    print_test "F5 Configuration Reload Test"

    if command -v kitty &> /dev/null; then
        # Test config reload via kitty remote control
        if kitty @ load-config 2>/dev/null; then
            print_success "Configuration reload successful"
        else
            print_warning "Direct config reload failed (try F5 in kitty window)"
        fi
    else
        print_warning "Cannot test reload - kitty not in PATH"
    fi
}

# Test context menu
test_context_menu() {
    print_section "Testing Context Menu System"

    print_info "Testing context menu script execution..."

    local script_path="$KITTY_CONFIG_DIR/scripts/context_menu.sh"

    if [[ ! -f "$script_path" ]]; then
        print_warning "Context menu script not found at $script_path"
        return 1
    fi

    print_test "Script execution test"

    # Test in a controlled way
    cat << EOF
${CYAN}Context Menu Test Instructions:${NC}

${BLUE}Method 1 - Right Click:${NC}
1. Right-click in any kitty window
2. You should see a context menu with options like:
   - Copy/Paste
   - Clear Screen
   - New Tab/Window
   - Search (if text is selected)

${BLUE}Method 2 - Keyboard Shortcut:${NC}
1. Press Ctrl+Shift+M in kitty
2. Same menu should appear

${BLUE}Method 3 - Direct Test:${NC}
We'll test the script directly now...

EOF

    # Try to run the script in a safe way
    if timeout 10s bash -c "DISPLAY=${DISPLAY:-:0} '$script_path'" 2>/dev/null &
    then
        local pid=$!
        sleep 2
        if kill -0 $pid 2>/dev/null; then
            print_success "Context menu script launched successfully"
            kill $pid 2>/dev/null || true
        else
            print_warning "Context menu script exited quickly (may be normal)"
        fi
    else
        print_warning "Could not test context menu directly"
    fi

    wait_for_user
}

# Test mouse mappings
test_mouse_mappings() {
    print_section "Testing Mouse Mappings"

    cat << EOF
${CYAN}Mouse Mapping Test Instructions:${NC}

${BLUE}Right Click:${NC}
- Right-click in kitty terminal
- Should show context menu with copy/paste options

${BLUE}Ctrl + Right Click:${NC}
- Hold Ctrl and right-click
- Should show enhanced context menu

${BLUE}Middle Click:${NC}
- Middle-click (or click scroll wheel)
- Should paste from primary selection

${BLUE}Ctrl + Middle Click:${NC}
- Hold Ctrl and middle-click
- Should paste from clipboard

${YELLOW}Try these mouse actions now and verify they work correctly.${NC}

EOF

    wait_for_user
}

# Test clipboard functionality
test_clipboard() {
    print_section "Testing Clipboard Integration"

    print_test "Clipboard tools availability"

    if command -v xclip &> /dev/null; then
        print_success "xclip found"

        # Test clipboard functionality
        print_test "Clipboard write/read test"

        local test_text="KITTYVONCAN clipboard test $(date)"
        echo -n "$test_text" | xclip -selection clipboard

        local read_text=$(xclip -selection clipboard -o 2>/dev/null)

        if [[ "$read_text" == "$test_text" ]]; then
            print_success "Clipboard read/write working"
        else
            print_warning "Clipboard test failed"
        fi
    else
        print_warning "xclip not found - clipboard features may not work"
    fi

    cat << EOF

${CYAN}Manual Clipboard Test Instructions:${NC}

${BLUE}Copy Test:${NC}
1. Select some text in kitty
2. Press Ctrl+Shift+C
3. Text should be copied to clipboard

${BLUE}Paste Test:${NC}
1. With text in clipboard
2. Press Ctrl+Shift+V
3. Text should be pasted

${BLUE}Selection Paste:${NC}
1. Select text with mouse
2. Middle-click elsewhere
3. Text should be pasted from selection

EOF

    wait_for_user
}

# Test themes and appearance
test_themes() {
    print_section "Testing Themes and Appearance"

    print_test "Font configuration"

    if fc-list | grep -i "jetbrains mono" &> /dev/null; then
        print_success "JetBrains Mono font available"
    else
        print_warning "JetBrains Mono font not found"
    fi

    print_test "Theme files"

    local theme_file="$KITTY_CONFIG_DIR/themes/nord.conf"
    if [[ -f "$theme_file" ]]; then
        print_success "Nord theme file found"
    else
        print_warning "Nord theme file not found"
    fi

    cat << EOF

${CYAN}Appearance Test Instructions:${NC}

${BLUE}Font Rendering:${NC}
- Text should be rendered in JetBrains Mono font
- Font should have programming ligatures (if supported)
- Font size should be comfortable for development

${BLUE}Color Scheme:${NC}
- Background should be dark (if using Nord theme)
- Text should have good contrast
- Syntax highlighting should work in editors

${BLUE}Window Appearance:${NC}
- Window borders should be minimal
- Tab bar should be visible with multiple tabs
- Window padding should provide comfortable spacing

${YELLOW}Verify the appearance looks professional and readable.${NC}

EOF

    wait_for_user
}

# Test session management
test_session_management() {
    print_section "Testing Session Management"

    cat << EOF
${CYAN}Session Management Test Instructions:${NC}

${BLUE}Tab Management:${NC}
- Ctrl+Shift+T: New tab
- Ctrl+Shift+W: Close tab
- Ctrl+Shift+Right/Left: Switch tabs

${BLUE}Window Management:${NC}
- Ctrl+Shift+Enter: New window
- Ctrl+Shift+N: New OS window
- F4: New window with current directory

${BLUE}Session Shortcuts:${NC}
- Ctrl+Alt+S: New tab with current directory
- Ctrl+Alt+T: Set tab title
- Ctrl+Alt+N: New OS window with current directory

${BLUE}Layout Management:${NC}
- Ctrl+Shift+L: Next layout
- Various Ctrl+Shift+Alt combinations for specific layouts

${YELLOW}Test these shortcuts to verify session management works.${NC}

EOF

    wait_for_user
}

# Test development workflow
test_development_workflow() {
    print_section "Testing Development Workflow Integration"

    cat << EOF
${CYAN}Development Workflow Test Instructions:${NC}

${BLUE}Quick Editor Access:${NC}
- F1: Should launch Neovim in current directory
- Ctrl+Alt+C: Should launch VS Code in current directory

${BLUE}File Management:${NC}
- F2: Should launch Ranger file manager
- Ctrl+Alt+F: Should launch file manager (Thunar)

${BLUE}System Monitoring:${NC}
- F3: Should launch htop system monitor
- F9: Should show Claude logs (if available)

${BLUE}Git Integration:${NC}
- F7: Should show git status overlay
- Should work in any git repository

${BLUE}Quick Shell:${NC}
- F12: Should open shell overlay
- Should preserve current working directory

${YELLOW}Test these integrations in a project directory.${NC}

EOF

    wait_for_user
}

# Test performance and responsiveness
test_performance() {
    print_section "Testing Performance and Responsiveness"

    print_test "Configuration performance settings"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if grep -q "repaint_delay" "$config_file" 2>/dev/null; then
        local repaint_delay=$(grep "repaint_delay" "$config_file" | awk '{print $2}')
        print_success "Repaint delay configured: ${repaint_delay}ms"
    fi

    if grep -q "input_delay" "$config_file" 2>/dev/null; then
        local input_delay=$(grep "input_delay" "$config_file" | awk '{print $2}')
        print_success "Input delay configured: ${input_delay}ms"
    fi

    cat << EOF

${CYAN}Performance Test Instructions:${NC}

${BLUE}Responsiveness Test:${NC}
1. Type rapidly in the terminal
2. Input should appear without noticeable delay
3. Scrolling should be smooth

${BLUE}Large Output Test:${NC}
1. Run: cat /var/log/syslog (or similar large file)
2. Scrolling should remain responsive
3. No significant lag during rapid output

${BLUE}Multi-tab Performance:${NC}
1. Open several tabs (Ctrl+Shift+T)
2. Switch between tabs (Ctrl+Shift+Left/Right)
3. Switching should be instant

${BLUE}Context Menu Performance:${NC}
1. Right-click multiple times
2. Menu should appear quickly each time
3. No memory leaks or slowdowns

${YELLOW}Verify that kitty feels responsive and performant.${NC}

EOF

    wait_for_user
}

# Test remote control functionality
test_remote_control() {
    print_section "Testing Remote Control Features"

    print_test "Remote control configuration"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if grep -q "allow_remote_control.*yes" "$config_file" 2>/dev/null; then
        print_success "Remote control enabled"
    else
        print_warning "Remote control not enabled"
        return 1
    fi

    if command -v kitty &> /dev/null; then
        print_test "Remote control functionality"

        # Test basic remote control
        if kitty @ ls &>/dev/null; then
            print_success "Remote control communication working"
        else
            print_warning "Remote control not responding (kitty may not be running)"
        fi
    fi

    cat << EOF

${CYAN}Remote Control Test Instructions:${NC}

${BLUE}Configuration Reload:${NC}
- F5 should reload configuration using remote control
- Changes should apply immediately

${BLUE}Context Menu Integration:${NC}
- Context menu uses remote control for some functions
- Should work seamlessly with kitty

${BLUE}Advanced Features:${NC}
- Some KITTYVONCAN features require remote control
- Verify no permission errors occur

EOF

    wait_for_user
}

# Run comprehensive test
run_comprehensive_test() {
    print_header

    print_info "This will run through all KITTYVONCAN features interactively."
    print_info "Follow the instructions and verify each feature works correctly."
    echo

    wait_for_user

    # Run all tests
    test_function_keys
    test_context_menu
    test_mouse_mappings
    test_clipboard
    test_themes
    test_session_management
    test_development_workflow
    test_performance
    test_remote_control

    # Final summary
    print_section "Testing Complete"

    cat << EOF
${GREEN}🎉 KITTYVONCAN feature testing completed!${NC}

${CYAN}If all features worked correctly:${NC}
- Your KITTYVONCAN installation is fully functional
- You can enjoy professional kitty terminal enhancements
- All development workflow integrations are working

${CYAN}If some features didn't work:${NC}
- Run ./tests/validate_config.sh for detailed diagnostics
- Check that all dependencies are installed
- Verify kitty configuration syntax

${CYAN}For support:${NC}
- Check the README.md for troubleshooting
- Review configuration in ~/.config/kitty/kitty.conf
- Test individual components as needed

${YELLOW}Thank you for testing KITTYVONCAN! 🐱${NC}

EOF
}

# Quick test mode
run_quick_test() {
    echo -e "${CYAN}Running quick validation...${NC}"

    # Just run the config validator
    local validator="$(dirname "$0")/validate_config.sh"
    if [[ -x "$validator" ]]; then
        "$validator"
    else
        echo -e "${RED}Validator script not found or not executable${NC}"
        exit 1
    fi
}

# Show help
show_help() {
    cat << EOF
KITTYVONCAN Feature Testing Script

USAGE:
    ./test_features.sh [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -i, --interactive   Run interactive feature tests (default)
    -q, --quick         Run quick validation only
    -a, --automated     Run automated tests (no user interaction)

DESCRIPTION:
    This script tests all KITTYVONCAN features to ensure they work correctly
    after installation. It includes tests for:

    - F-key development shortcuts
    - Context menu system
    - Mouse mappings
    - Clipboard integration
    - Themes and appearance
    - Session management
    - Development workflow
    - Performance settings
    - Remote control features

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
            -i|--interactive)
                TEST_MODE="interactive"
                shift
                ;;
            -q|--quick)
                TEST_MODE="quick"
                shift
                ;;
            -a|--automated)
                TEST_MODE="automated"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    parse_args "$@"

    case "$TEST_MODE" in
        "quick")
            run_quick_test
            ;;
        "interactive")
            run_comprehensive_test
            ;;
        "automated")
            print_warning "Automated testing not yet implemented"
            run_quick_test
            ;;
        *)
            echo "Invalid test mode: $TEST_MODE"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
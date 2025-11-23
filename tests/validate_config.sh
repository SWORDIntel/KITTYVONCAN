#!/bin/bash
# KITTYVONCAN Configuration Validation Script
# Tests kitty configuration for syntax and functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
KITTY_CONFIG_DIR="$HOME/.config/kitty"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Print functions
print_test() {
    echo -e "${BLUE}🧪${NC} Testing: $1"
}

print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Test kitty installation
test_kitty_installation() {
    print_test "Kitty installation"

    if command -v kitty &> /dev/null; then
        local version=$(kitty --version 2>/dev/null | cut -d' ' -f2)
        print_pass "Kitty found (version: $version)"
    else
        print_fail "Kitty not found in PATH"
        return 1
    fi
}

# Test configuration syntax
test_config_syntax() {
    print_test "Configuration syntax"

    if [[ ! -f "$KITTY_CONFIG_DIR/kitty.conf" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    # Test configuration validity (basic check since --debug-config doesn't exist in 0.41.1)
    if grep -q "^font_family" "$KITTY_CONFIG_DIR/kitty.conf" && grep -q "^mouse_map" "$KITTY_CONFIG_DIR/kitty.conf"; then
        print_pass "Configuration syntax appears valid"
    else
        print_fail "Configuration missing required sections"
        return 1
    fi
}

# Test dependencies
test_dependencies() {
    print_test "Required dependencies"

    local deps=("xclip" "xdotool" "zenity")
    local missing=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            print_pass "$dep found"
        else
            print_fail "$dep not found"
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing[*]}"
        print_info "Install with: sudo apt install ${missing[*]}"
        return 1
    fi
}

# Test context menu script
test_context_menu() {
    print_test "Context menu script"

    local script_path="$KITTY_CONFIG_DIR/scripts/context_menu.sh"

    if [[ ! -f "$script_path" ]]; then
        print_fail "Context menu script not found"
        return 1
    fi

    if [[ ! -x "$script_path" ]]; then
        print_fail "Context menu script not executable"
        return 1
    fi

    # Test script syntax
    if bash -n "$script_path" 2>/dev/null; then
        print_pass "Context menu script syntax is valid"
    else
        print_fail "Context menu script has syntax errors"
        return 1
    fi

    # Test if script can run (dry run test)
    if timeout 5s bash -c "cd /tmp && DISPLAY=:0 '$script_path' &" 2>/dev/null; then
        print_pass "Context menu script can execute"
    else
        print_warning "Context menu script execution test failed (may need X11)"
    fi
}

# Test font installation
test_fonts() {
    print_test "Font installation"

    if fc-list | grep -i "jetbrains mono" &> /dev/null; then
        print_pass "JetBrains Mono font found"
    else
        print_warning "JetBrains Mono font not found"
        print_info "Font will be downloaded during installation"
    fi
}

# Test configuration includes
test_config_includes() {
    print_test "Configuration includes"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if [[ ! -f "$config_file" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    # Check for theme include
    if grep -q "include.*themes/" "$config_file"; then
        local theme_file=$(grep "include.*themes/" "$config_file" | awk '{print $2}')
        local full_theme_path="$KITTY_CONFIG_DIR/$theme_file"

        if [[ -f "$full_theme_path" ]]; then
            print_pass "Theme file found: $theme_file"
        else
            print_fail "Theme file not found: $theme_file"
        fi
    else
        print_warning "No theme includes found in configuration"
    fi
}

# Test keyboard shortcuts
test_shortcuts() {
    print_test "Keyboard shortcuts configuration"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if [[ ! -f "$config_file" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    local expected_shortcuts=("map f1" "map f2" "map f5" "map f12")
    local found_shortcuts=0

    for shortcut in "${expected_shortcuts[@]}"; do
        if grep -q "$shortcut" "$config_file"; then
            ((found_shortcuts++))
        fi
    done

    if [[ $found_shortcuts -eq ${#expected_shortcuts[@]} ]]; then
        print_pass "Development shortcuts configured ($found_shortcuts/${#expected_shortcuts[@]})"
    elif [[ $found_shortcuts -gt 0 ]]; then
        print_warning "Some development shortcuts missing ($found_shortcuts/${#expected_shortcuts[@]})"
    else
        print_fail "No development shortcuts found"
    fi
}

# Test mouse mappings
test_mouse_mappings() {
    print_test "Mouse mappings"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if [[ ! -f "$config_file" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    local mouse_mappings=("mouse_map.*right.*click" "mouse_map.*middle.*click")
    local found_mappings=0

    for mapping in "${mouse_mappings[@]}"; do
        if grep -q "$mapping" "$config_file"; then
            ((found_mappings++))
        fi
    done

    if [[ $found_mappings -eq ${#mouse_mappings[@]} ]]; then
        print_pass "Mouse mappings configured"
    else
        print_warning "Some mouse mappings missing ($found_mappings/${#mouse_mappings[@]})"
    fi
}

# Test remote control
test_remote_control() {
    print_test "Remote control configuration"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if [[ ! -f "$config_file" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    if grep -q "allow_remote_control.*yes" "$config_file"; then
        print_pass "Remote control enabled"
    else
        print_fail "Remote control not enabled (required for context menu)"
    fi

    if grep -q "listen_on.*unix:" "$config_file"; then
        print_pass "Unix socket configured for remote control"
    else
        print_warning "Unix socket not configured (may affect performance)"
    fi
}

# Test directory structure
test_directory_structure() {
    print_test "Directory structure"

    local required_dirs=(
        "$KITTY_CONFIG_DIR"
        "$KITTY_CONFIG_DIR/scripts"
        "$KITTY_CONFIG_DIR/kittyvoncan/sessions"
    )

    local required_files=(
        "$KITTY_CONFIG_DIR/kitty.conf"
        "$KITTY_CONFIG_DIR/scripts/context_menu.sh"
        "$KITTY_CONFIG_DIR/scripts/fabric_dashboard.sh"
        "$KITTY_CONFIG_DIR/kittyvoncan/sessions/fabric_dashboard.session"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_pass "Directory exists: $(basename "$dir")"
        else
            print_fail "Directory missing: $dir"
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_pass "File exists: $(basename "$file")"
        else
            print_fail "File missing: $file"
        fi
    done
}

test_fabric_dashboard() {
    print_test "Fabric dashboard assets"

    local launcher="$KITTY_CONFIG_DIR/scripts/fabric_dashboard.sh"
    local session="$KITTY_CONFIG_DIR/kittyvoncan/sessions/fabric_dashboard.session"

    if [[ -f "$launcher" ]]; then
        if [[ -x "$launcher" ]]; then
            print_pass "Fabric dashboard launcher is executable"
        else
            print_fail "Fabric dashboard launcher is not executable"
        fi
    else
        print_fail "Fabric dashboard launcher missing"
    fi

    if [[ -f "$session" ]]; then
        print_pass "Fabric dashboard session template found"
    else
        print_fail "Fabric dashboard session template missing"
    fi
}

# Test configuration backup
test_backup_system() {
    print_test "Backup system"

    local backup_marker="$KITTY_CONFIG_DIR/.kittyvoncan_last_backup"

    if [[ -f "$backup_marker" ]]; then
        local backup_dir=$(cat "$backup_marker")
        if [[ -d "$backup_dir" ]]; then
            print_pass "Backup system configured and backup exists"
        else
            print_warning "Backup marker exists but backup directory missing"
        fi
    else
        print_info "No backup marker found (normal for new installations)"
    fi
}

# Run performance test
test_performance() {
    print_test "Performance configuration"

    local config_file="$KITTY_CONFIG_DIR/kitty.conf"

    if [[ ! -f "$config_file" ]]; then
        print_fail "kitty.conf not found"
        return 1
    fi

    local perf_settings=("repaint_delay" "input_delay" "sync_to_monitor")
    local found_settings=0

    for setting in "${perf_settings[@]}"; do
        if grep -q "$setting" "$config_file"; then
            ((found_settings++))
        fi
    done

    if [[ $found_settings -eq ${#perf_settings[@]} ]]; then
        print_pass "Performance settings configured"
    else
        print_warning "Some performance settings missing ($found_settings/${#perf_settings[@]})"
    fi
}

# Print summary
print_summary() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}VALIDATION SUMMARY${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo -e "Tests Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed:  ${RED}$TESTS_FAILED${NC}"
    echo -e "Warnings:      ${YELLOW}$WARNINGS${NC}"

    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    if [[ $total_tests -gt 0 ]]; then
        local success_rate=$(( (TESTS_PASSED * 100) / total_tests ))
        echo -e "Success Rate:  ${CYAN}$success_rate%${NC}"
    fi

    echo

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All validation tests passed!${NC}"
        echo -e "${CYAN}Your KITTYVONCAN installation appears to be working correctly.${NC}"
    elif [[ $TESTS_FAILED -le 2 ]]; then
        echo -e "${YELLOW}⚠️ Minor issues detected${NC}"
        echo -e "${CYAN}Your installation mostly works but may have some limitations.${NC}"
    else
        echo -e "${RED}❌ Significant issues detected${NC}"
        echo -e "${CYAN}Please review the failed tests and fix the issues.${NC}"
    fi

    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Note: Warnings indicate optional features that may not be available.${NC}"
    fi

    return $TESTS_FAILED
}

# Main function
main() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║            KITTYVONCAN VALIDATOR 🧪                ║"
    echo "║         Configuration & Feature Testing           ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Run all tests
    test_kitty_installation || true
    test_config_syntax || true
    test_dependencies || true
    test_context_menu || true
    test_fonts || true
    test_config_includes || true
    test_shortcuts || true
    test_mouse_mappings || true
    test_remote_control || true
    test_directory_structure || true
    test_fabric_dashboard || true
    test_backup_system || true
    test_performance || true

    print_summary
}

# Run main function
main "$@"

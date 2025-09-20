#!/bin/bash
# Context Menu Status Checker

echo "🐱 Kitty Context Menu Status Check"
echo "=================================="

# Check script files
echo "📁 Script Files:"
if [ -f ~/.config/kitty/scripts/context_menu.sh ]; then
    echo "  ✅ context_menu.sh - $(wc -l < ~/.config/kitty/scripts/context_menu.sh) lines"
    [ -x ~/.config/kitty/scripts/context_menu.sh ] && echo "     📋 Executable: Yes" || echo "     ❌ Executable: No"
else
    echo "  ❌ context_menu.sh - Missing"
fi

if [ -f ~/.config/kitty/scripts/test_menu.sh ]; then
    echo "  ✅ test_menu.sh - Available"
else
    echo "  ❌ test_menu.sh - Missing"
fi

# Check rofi configuration
echo ""
echo "🎨 Rofi Configuration:"
if command -v rofi >/dev/null 2>&1; then
    echo "  ✅ Rofi installed: $(rofi -version | head -1)"

    if [ -f ~/.config/rofi/context-menu.rasi ]; then
        echo "  ✅ Custom theme: context-menu.rasi"
    else
        echo "  ⚠️  Custom theme: Missing (will use fallback)"
    fi

    if [ -f ~/.config/rofi/config.rasi ]; then
        echo "  ✅ Rofi config: config.rasi"
    else
        echo "  ⚠️  Rofi config: Using defaults"
    fi
else
    echo "  ❌ Rofi: Not installed"
fi

# Check fallback options
echo ""
echo "🔄 Fallback Options:"
if command -v zenity >/dev/null 2>&1; then
    echo "  ✅ Zenity: Available"
else
    echo "  ❌ Zenity: Not available"
fi

# Check clipboard tools
echo ""
echo "📋 Clipboard Support:"
if command -v xclip >/dev/null 2>&1; then
    echo "  ✅ xclip: Available (X11)"
else
    echo "  ❌ xclip: Not available"
fi

if command -v wl-copy >/dev/null 2>&1; then
    echo "  ✅ wl-copy: Available (Wayland)"
else
    echo "  ❌ wl-copy: Not available"
fi

# Check notification support
echo ""
echo "🔔 Notification Support:"
if command -v notify-send >/dev/null 2>&1; then
    echo "  ✅ notify-send: Available"
else
    echo "  ❌ notify-send: Not available"
fi

# Check kitty configuration
echo ""
echo "🐱 Kitty Configuration:"
if [ -f ~/.config/kitty/kitty.conf ]; then
    echo "  ✅ kitty.conf: Found"

    # Check for mouse mappings
    if grep -q "context_menu.sh" ~/.config/kitty/kitty.conf; then
        echo "  ✅ Mouse mapping: Configured"
        echo "     $(grep "context_menu.sh" ~/.config/kitty/kitty.conf | head -1 | sed 's/^[[:space:]]*/     /')"
    else
        echo "  ⚠️  Mouse mapping: Not found in config"
        echo "     Add: mouse_map ctrl+right click ungrabbed launch --type=overlay ~/.config/kitty/scripts/context_menu.sh"
    fi

    # Check for remote control
    if grep -q "allow_remote_control" ~/.config/kitty/kitty.conf; then
        echo "  ✅ Remote control: Configured"
    else
        echo "  ⚠️  Remote control: May need 'allow_remote_control yes'"
    fi
else
    echo "  ❌ kitty.conf: Not found"
fi

# Overall status
echo ""
echo "📊 Overall Status:"

CRITICAL_MISSING=0
WARNINGS=0

# Critical checks
[ ! -f ~/.config/kitty/scripts/context_menu.sh ] && CRITICAL_MISSING=$((CRITICAL_MISSING + 1))
[ ! -x ~/.config/kitty/scripts/context_menu.sh ] && CRITICAL_MISSING=$((CRITICAL_MISSING + 1))
! command -v rofi >/dev/null 2>&1 && ! command -v zenity >/dev/null 2>&1 && CRITICAL_MISSING=$((CRITICAL_MISSING + 1))

# Warning checks
[ ! -f ~/.config/rofi/context-menu.rasi ] && WARNINGS=$((WARNINGS + 1))
! command -v xclip >/dev/null 2>&1 && ! command -v wl-copy >/dev/null 2>&1 && WARNINGS=$((WARNINGS + 1))
! grep -q "context_menu.sh" ~/.config/kitty/kitty.conf 2>/dev/null && WARNINGS=$((WARNINGS + 1))

if [ $CRITICAL_MISSING -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "  🎉 STATUS: FULLY FUNCTIONAL"
        echo "     All components installed and configured properly"
    else
        echo "  ✅ STATUS: FUNCTIONAL with $WARNINGS warning(s)"
        echo "     Core functionality works, some features may be limited"
    fi
    echo ""
    echo "🚀 To test: Ctrl+Right-click in kitty terminal"
else
    echo "  ❌ STATUS: NOT FUNCTIONAL - $CRITICAL_MISSING critical issue(s)"
    echo "     Please fix critical issues before use"
fi

echo ""
echo "📖 For help: cat ~/.config/kitty/scripts/README_CONTEXT_MENU.md"
#!/bin/bash
# Test script for rofi menu functionality

echo "Testing rofi menu functionality..."

# Test basic rofi
echo "1. Testing basic rofi..."
TEST_OPTIONS=("Option 1" "Option 2" "Option 3" "Exit")
CHOICE=$(printf '%s\n' "${TEST_OPTIONS[@]}" | rofi -dmenu -p "Test Menu" 2>/dev/null)
echo "Selected: $CHOICE"

# Test with custom theme
echo "2. Testing with custom theme..."
ROFI_THEME="$HOME/.config/rofi/context-menu.rasi"
if [ -f "$ROFI_THEME" ]; then
    STYLED_OPTIONS=("📋 Copy" "📝 Paste" "🗑️ Clear" "❌ Cancel")
    STYLED_CHOICE=$(printf '%s\n' "${STYLED_OPTIONS[@]}" | rofi -dmenu -p "🐱 Styled Test" -theme "$ROFI_THEME" 2>/dev/null)
    echo "Styled choice: $STYLED_CHOICE"
else
    echo "Theme file not found: $ROFI_THEME"
fi

# Test zenity fallback
echo "3. Testing zenity fallback..."
if command -v zenity >/dev/null 2>&1; then
    ZENITY_CHOICE=$(zenity --list --title="Test Zenity" --text="Choose option:" --column="Option" "Option A" "Option B" --height=300 --width=250 2>/dev/null)
    echo "Zenity choice: $ZENITY_CHOICE"
else
    echo "Zenity not available"
fi

echo "Menu test completed."
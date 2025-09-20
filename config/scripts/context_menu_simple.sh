#!/bin/bash
# Simple Kitty Context Menu - Zenity Only
# Fallback script for systems without rofi

# Get current selection if any
SELECTION=$(kitty @ get-text --extent=selection 2>/dev/null || echo "")

# Define menu based on selection
if [ -n "$SELECTION" ]; then
    CHOICE=$(zenity --list --title="Kitty Menu" \
        --text="Selection: $(echo "$SELECTION" | cut -c1-30)..." \
        --column="Action" \
        "Copy Selection" \
        "Paste" \
        "Clear Terminal" \
        "Open URL Hints" \
        "New Tab" \
        "New Window" \
        --height=300 --width=250 2>/dev/null)
else
    CHOICE=$(zenity --list --title="Kitty Menu" \
        --text="Right-click menu" \
        --column="Action" \
        "Paste" \
        "Select All" \
        "Clear Terminal" \
        "Open URL Hints" \
        "New Tab" \
        "New Window" \
        --height=300 --width=250 2>/dev/null)
fi

# Execute action
case "$CHOICE" in
    "Copy Selection")
        echo -n "$SELECTION" | xclip -selection clipboard
        ;;
    "Paste")
        CLIPBOARD=$(xclip -selection clipboard -o)
        kitty @ send-text --match=recent "$CLIPBOARD"
        ;;
    "Select All")
        kitty @ send-text --match=recent $'\001'
        ;;
    "Clear Terminal")
        kitty @ send-text --match=recent $'\014'
        ;;
    "Open URL Hints")
        kitty @ kitten hints --type=url
        ;;
    "New Tab")
        kitty @ new-tab --cwd=current
        ;;
    "New Window")
        kitty @ new-window --cwd=current
        ;;
esac
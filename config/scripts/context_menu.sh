#!/bin/bash
# Simple Kitty Context Menu - Working Version

# Get current selection if any
SELECTION=$(xclip -selection primary -o 2>/dev/null | head -c 30)

# Define menu options
if [ -n "$SELECTION" ]; then
    OPTIONS="Copy Selection\nPaste\nClear Screen\nSearch: ${SELECTION}...\nNew Tab\nNew Window"
else
    OPTIONS="Copy\nPaste\nClear Screen\nSelect All\nNew Tab\nNew Window"
fi

# Show menu with zenity (reliable)
choice=$(echo -e "$OPTIONS" | zenity --list --title="Terminal Menu" --text="Choose action:" --column="Action" --width=250 --height=300 2>/dev/null)

# Execute action
case "$choice" in
    "Copy"|"Copy Selection")
        # Copy to clipboard
        if [ -n "$SELECTION" ]; then
            echo -n "$SELECTION" | xclip -selection clipboard
        fi
        ;;
    "Paste")
        # Get clipboard and type it
        clip=$(xclip -selection clipboard -o 2>/dev/null)
        if [ -n "$clip" ]; then
            xdotool type --clearmodifiers "$clip"
        fi
        ;;
    "Clear Screen")
        xdotool key ctrl+l
        ;;
    "Select All")
        xdotool key ctrl+shift+a
        ;;
    "Search:"*)
        # Open search in browser
        search_term=$(echo "$choice" | sed 's/Search: //' | sed 's/\.\.\.//')
        xdg-open "https://www.google.com/search?q=$(echo "$search_term" | sed 's/ /+/g')" 2>/dev/null &
        ;;
    "New Tab")
        xdotool key ctrl+shift+t
        ;;
    "New Window")
        kitty &
        ;;
esac
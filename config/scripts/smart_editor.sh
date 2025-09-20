#!/bin/bash
# Smart Editor Launcher - KITTYVONCAN
# Launches the best available text editor with helpful guidance

show_editor_help() {
    zenity --info --title="Editor Options" --width=500 --text="
<b>Popular Text Editors for Development:</b>

<b>📝 Sublime Text (Recommended)</b>
• Install: wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
• Then: sudo apt install sublime-text

<b>🆚 Visual Studio Code</b>
• Install: sudo snap install code --classic
• Or: sudo apt install code

<b>⚡ Gedit (Simple & Fast)</b>
• Install: sudo apt install gedit

<b>📄 Kate (KDE Editor)</b>
• Install: sudo apt install kate

<b>🔥 Atom (GitHub)</b>
• Install: sudo snap install atom --classic

<b>📋 Mousepad (Lightweight)</b>
• Install: sudo apt install mousepad

<b>🖥️ Terminal Editors</b>
• nano (pre-installed)
• vim: sudo apt install vim
• neovim: sudo apt install neovim

Choose your preferred editor and install it, then F1 will work perfectly!"
}

# Priority order for editor detection
EDITORS=(
    "subl:Sublime Text:https://www.sublimetext.com"
    "code:Visual Studio Code:sudo snap install code --classic"
    "gedit:Gedit:sudo apt install gedit"
    "kate:Kate:sudo apt install kate"
    "atom:Atom:sudo snap install atom --classic"
    "mousepad:Mousepad:sudo apt install mousepad"
    "vim:Vim:sudo apt install vim"
    "nvim:Neovim:sudo apt install neovim"
    "nano:Nano:(pre-installed)"
)

# Check for available editors
for editor_info in "${EDITORS[@]}"; do
    IFS=':' read -r cmd name install <<< "$editor_info"

    if command -v "$cmd" >/dev/null 2>&1; then
        # Found an editor, launch it
        case "$cmd" in
            "subl")
                # Sublime Text - open current directory
                subl . 2>/dev/null &
                ;;
            "code")
                # VS Code - open current directory
                code . 2>/dev/null &
                ;;
            "gedit"|"kate"|"atom"|"mousepad")
                # GUI editors - open current directory or new file
                "$cmd" . 2>/dev/null &
                ;;
            "vim"|"nvim")
                # Terminal editors - launch in current terminal
                "$cmd"
                ;;
            "nano")
                # Nano - simple terminal editor
                nano
                ;;
        esac
        exit 0
    fi
done

# No suitable editor found - show help
zenity --question --title="No Editor Found" --text="No suitable text editor found on your system.

Would you like to see installation options for popular editors?" --width=400

if [ $? -eq 0 ]; then
    show_editor_help
else
    # Fallback to basic editor
    if command -v nano >/dev/null 2>&1; then
        nano
    else
        echo "Please install a text editor. Popular choices:"
        echo "• Sublime Text: wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - && sudo apt install sublime-text"
        echo "• VS Code: sudo snap install code --classic"
        echo "• Gedit: sudo apt install gedit"
    fi
fi
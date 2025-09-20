# KITTYVONCAN Troubleshooting Guide

## Quick Diagnostics

### Run the Validation Script
```bash
# Comprehensive system check
./tests/validate_config.sh

# Interactive feature testing
./tests/test_features.sh
```

### Check Installation Status
```bash
# Verify kitty configuration
kitty --debug-config

# Test context menu directly
~/.config/kitty/scripts/context_menu.sh

# Check dependencies
which xclip xdotool zenity
```

## Common Issues and Solutions

### 1. Context Menu Not Working

#### Symptoms
- Right-click does nothing
- Ctrl+Shift+M shows no menu
- Error messages about missing dependencies

#### Diagnostic Steps
```bash
# Check if dependencies are installed
which xclip && echo "xclip: OK" || echo "xclip: MISSING"
which xdotool && echo "xdotool: OK" || echo "xdotool: MISSING"
which zenity && echo "zenity: OK" || echo "zenity: MISSING"

# Test script execution
bash -x ~/.config/kitty/scripts/context_menu.sh

# Check X11/Wayland session
echo "Session type: $XDG_SESSION_TYPE"
echo "Display: $DISPLAY"
```

#### Solutions

**Missing Dependencies:**
```bash
# Ubuntu/Debian
sudo apt install xclip xdotool zenity

# Fedora/RHEL
sudo dnf install xclip xdotool zenity

# Arch Linux
sudo pacman -S xclip xdotool zenity
```

**Script Permission Issues:**
```bash
# Fix script permissions
chmod +x ~/.config/kitty/scripts/context_menu.sh

# Test script syntax
bash -n ~/.config/kitty/scripts/context_menu.sh
```

**Wayland Compatibility:**
```bash
# For Wayland, install wl-clipboard
sudo apt install wl-clipboard  # Ubuntu/Debian
sudo dnf install wl-clipboard  # Fedora

# Or use X11 session for full compatibility
# Select "GNOME on Xorg" at login screen
```

### 2. F-Key Shortcuts Not Working

#### Symptoms
- F1-F12 keys do nothing
- Default system shortcuts take precedence
- Shortcuts work in some applications but not others

#### Diagnostic Steps
```bash
# Check kitty configuration
grep "map f[0-9]" ~/.config/kitty/kitty.conf

# Test configuration reload
kitty @ load-config

# Check for conflicting shortcuts
# System Settings > Keyboard > Shortcuts
```

#### Solutions

**Configuration Issues:**
```bash
# Reload kitty configuration
kitty @ load-config
# Or press F5 in kitty

# Verify syntax
kitty --debug-config

# Check remote control is enabled
grep "allow_remote_control" ~/.config/kitty/kitty.conf
```

**System Shortcut Conflicts:**
1. Open System Settings
2. Go to Keyboard > Shortcuts
3. Check for F-key conflicts
4. Disable conflicting system shortcuts

**Terminal-Specific Issues:**
```bash
# Test in clean kitty session
kitty --config=NONE

# Check if shortcuts work in other kitty windows
kitty --session=none
```

### 3. Font Issues

#### Symptoms
- JetBrains Mono not displaying
- Font fallback to system default
- Missing ligatures or special characters

#### Diagnostic Steps
```bash
# Check if font is installed
fc-list | grep -i "jetbrains mono"

# Check font configuration
grep "font_family" ~/.config/kitty/kitty.conf

# Test font cache
fc-cache -fv
```

#### Solutions

**Font Not Installed:**
```bash
# Install JetBrains Mono manually
./config/scripts/install_deps.sh --fonts-only

# Or download manually
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/JetBrains/JetBrainsMono/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -f
```

**Font Configuration Issues:**
```bash
# Check current font setting
grep "font_family" ~/.config/kitty/kitty.conf

# Set fallback font if needed
echo "font_family JetBrains Mono" >> ~/.config/kitty/kittyvoncan/custom.conf
```

**System Font Issues:**
```bash
# Clear font cache and rebuild
rm ~/.cache/fontconfig/*
fc-cache -f

# Check font permissions
ls -la ~/.local/share/fonts/
```

### 4. Configuration Errors

#### Symptoms
- Kitty fails to start
- Error messages on configuration reload
- Features not working despite installation

#### Diagnostic Steps
```bash
# Check configuration syntax
kitty --debug-config

# Test with minimal config
kitty --config=NONE

# Check for syntax errors
grep -n "map\|include\|set" ~/.config/kitty/kitty.conf
```

#### Solutions

**Syntax Errors:**
```bash
# Backup current config
cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup

# Restore from KITTYVONCAN backup
if [ -f ~/.config/kitty/.kittyvoncan_last_backup ]; then
    backup_dir=$(cat ~/.config/kitty/.kittyvoncan_last_backup)
    cp "$backup_dir/kitty.conf" ~/.config/kitty/kitty.conf
fi

# Or reinstall
./uninstall.sh --restore-original
./install.sh
```

**Include File Issues:**
```bash
# Check theme file exists
ls -la ~/.config/kitty/themes/nord.conf

# Test without theme
sed -i 's/^include themes/#include themes/' ~/.config/kitty/kitty.conf
kitty @ load-config
```

### 5. Performance Issues

#### Symptoms
- Slow startup
- Laggy scrolling
- High CPU usage
- Unresponsive context menu

#### Diagnostic Steps
```bash
# Check kitty performance
kitty --debug-performance

# Monitor resource usage
htop  # Look for kitty processes

# Test with minimal config
kitty --config=NONE --start-as=fullscreen
```

#### Solutions

**Configuration Optimization:**
```bash
# Edit performance settings in kitty.conf
repaint_delay 10          # Lower = more responsive
input_delay 3             # Lower = more responsive
sync_to_monitor yes       # Enable for smooth scrolling
```

**Script Optimization:**
```bash
# Use simpler context menu if needed
cp ~/.config/kitty/scripts/context_menu_simple.sh ~/.config/kitty/scripts/context_menu.sh

# Reduce context menu timeout
# Edit context_menu.sh and add timeouts to commands
```

**System Resources:**
```bash
# Check available memory
free -h

# Check for swap usage
swapon --show

# Close other applications if needed
```

### 6. Installation Issues

#### Symptoms
- Installer fails with errors
- Dependencies can't be installed
- Permission denied errors

#### Diagnostic Steps
```bash
# Run installer in dry-run mode
./install.sh --dry-run

# Check installer permissions
ls -la install.sh

# Check available disk space
df -h ~/.config/
```

#### Solutions

**Permission Issues:**
```bash
# Make installer executable
chmod +x install.sh

# Check kitty config directory permissions
ls -la ~/.config/
mkdir -p ~/.config/kitty
```

**Dependency Installation Failures:**
```bash
# Update package manager
sudo apt update          # Ubuntu/Debian
sudo dnf makecache      # Fedora

# Install dependencies manually
sudo apt install xclip xdotool zenity curl unzip

# Skip dependency installation
./install.sh --skip-deps
```

**Network Issues:**
```bash
# Test internet connectivity
ping github.com

# Use local installation if available
# Copy fonts manually instead of downloading
```

### 7. Uninstallation Issues

#### Symptoms
- Uninstaller doesn't restore original config
- Files remain after uninstallation
- Cannot find backup to restore

#### Solutions

**Manual Cleanup:**
```bash
# Remove KITTYVONCAN files
rm -rf ~/.config/kitty/kittyvoncan/
rm -f ~/.config/kitty/scripts/context_menu.sh
rm -f ~/.config/kitty/themes/nord.conf

# Create minimal config
cat > ~/.config/kitty/kitty.conf << 'EOF'
font_family monospace
font_size 12.0
EOF
```

**Restore Original Configuration:**
```bash
# Find backups
ls ~/.config/kitty/backups/

# Restore manually
backup_dir="~/.config/kitty/backups/kittyvoncan-YYYYMMDD-HHMMSS"
cp "$backup_dir/kitty.conf" ~/.config/kitty/
```

## Advanced Troubleshooting

### Debug Mode

**Enable Kitty Debug Logging:**
```bash
# Start kitty with debug output
kitty --debug-keyboard --debug-rendering

# Check kitty logs
journalctl --user -u kitty
```

**Script Debug Mode:**
```bash
# Run context menu with debug output
bash -x ~/.config/kitty/scripts/context_menu.sh

# Add debug to script temporarily
set -x  # Add at top of script
```

### Environment Issues

**Check Environment Variables:**
```bash
echo "DISPLAY: $DISPLAY"
echo "XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "PATH: $PATH"
```

**Test in Clean Environment:**
```bash
# Start with minimal environment
env -i HOME="$HOME" USER="$USER" kitty

# Test with different shell
kitty --shell=/bin/bash
```

### Compatibility Testing

**Test Different Scenarios:**
```bash
# Test SSH session
ssh localhost
# Then try KITTYVONCAN features

# Test different terminals
# Compare behavior in standard terminal vs kitty

# Test different desktop environments
# GNOME, KDE, XFCE compatibility
```

## Getting Additional Help

### Information to Gather

When reporting issues, include:

1. **System Information:**
   ```bash
   uname -a
   kitty --version
   echo $XDG_SESSION_TYPE
   ```

2. **Validation Output:**
   ```bash
   ./tests/validate_config.sh > validation_output.txt
   ```

3. **Error Messages:**
   ```bash
   kitty --debug-config 2>&1 | tee kitty_debug.log
   ```

4. **Configuration Files:**
   ```bash
   head -50 ~/.config/kitty/kitty.conf
   ```

### Support Channels

1. **GitHub Issues**: For bugs and feature requests
2. **Documentation**: Check all docs/ files
3. **Validation Scripts**: Run comprehensive tests
4. **Kitty Documentation**: Official kitty docs for base functionality

### Self-Diagnosis Checklist

- [ ] Dependencies installed (xclip, xdotool, zenity)
- [ ] Kitty version 0.21.0 or higher
- [ ] Configuration syntax valid (`kitty --debug-config`)
- [ ] Scripts executable (`ls -la ~/.config/kitty/scripts/`)
- [ ] Font installed (`fc-list | grep -i jetbrains`)
- [ ] Remote control enabled (`grep allow_remote_control`)
- [ ] No permission errors in logs
- [ ] X11/Wayland compatibility confirmed

---

*If this guide doesn't solve your issue, please open a GitHub issue with the diagnostic information above.*
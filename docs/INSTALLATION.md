# KITTYVONCAN Installation Guide

## Quick Start

The fastest way to get KITTYVONCAN up and running:

```bash
# One-line installation
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

## Detailed Installation

### Prerequisites

#### Required
- **kitty terminal** (v0.21.0 or higher)
- **Linux distribution** with X11 or Wayland
- **Internet connection** for font downloads

#### Dependencies (auto-installed)
- **xclip** - Clipboard operations
- **xdotool** - Keyboard automation
- **zenity** - Dialog boxes

#### Optional (enhances experience)
- **rofi** - Enhanced menu system
- **nvim/vim** - For F1 editor shortcut
- **ranger** - For F2 file manager shortcut
- **htop** - For F3 system monitor shortcut

### Installation Methods

#### Method 1: Quick Install (Recommended)

```bash
# Download and run installer
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash

# Or with wget
wget -qO- https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

#### Method 2: Git Clone Install

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/kittyvoncan.git
cd kittyvoncan

# Run installer
./install.sh
```

#### Method 3: Manual Download

```bash
# Download zip
wget https://github.com/YOUR_USERNAME/kittyvoncan/archive/main.zip
unzip main.zip
cd kittyvoncan-main

# Run installer
./install.sh
```

## Installation Options

### Standard Installation

```bash
# Full installation with all features
./install.sh --full
```

**Includes:**
- Complete kitty configuration
- JetBrains Mono font installation
- Context menu system
- All F-key shortcuts
- Development tool integration
- Nord theme

### Minimal Installation

```bash
# Core features only
./install.sh --minimal
```

**Includes:**
- Essential kitty configuration
- Context menu system
- Basic shortcuts
- Skip font installation
- Reduced dependencies

### Custom Installation

```bash
# Choose specific components
./install.sh --custom
```

**Interactive selection of:**
- Font installation
- Theme selection
- Shortcut configuration
- Development tool integration

### Advanced Options

```bash
# Preview changes without installing
./install.sh --dry-run

# Backup existing configuration only
./install.sh --backup-only

# Force installation without kitty check
./install.sh --force

# Skip dependency installation
./install.sh --skip-deps

# Automated installation (no prompts)
./install.sh --full --auto
```

## Platform-Specific Installation

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install kitty if not present
sudo apt install kitty

# Install KITTYVONCAN
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

### Fedora/RHEL

```bash
# Install kitty
sudo dnf install kitty

# Install KITTYVONCAN
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

### Arch Linux

```bash
# Install kitty
sudo pacman -S kitty

# Install KITTYVONCAN
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

### openSUSE

```bash
# Install kitty
sudo zypper install kitty

# Install KITTYVONCAN
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

## Installation Process

### What the Installer Does

1. **Environment Check**
   - Detects kitty installation
   - Identifies package manager
   - Checks system compatibility

2. **Dependency Installation**
   - Updates package cache
   - Installs required tools (xclip, xdotool, zenity)
   - Installs optional tools (rofi, development tools)

3. **Font Installation**
   - Downloads JetBrains Mono from GitHub
   - Extracts to user font directory
   - Updates system font cache

4. **Configuration Backup**
   - Creates timestamped backup of existing config
   - Preserves custom settings
   - Stores backup location for restoration

5. **File Installation**
   - Copies main kitty.conf
   - Installs context menu scripts
   - Sets up theme files
   - Creates custom configuration template

6. **Validation**
   - Tests configuration syntax
   - Verifies script permissions
   - Validates remote control setup

### File Locations

After installation, files are organized as:

```
~/.config/kitty/
├── kitty.conf                    # Main configuration
├── scripts/
│   ├── context_menu.sh            # Right-click menu
│   └── context_menu_simple.sh     # Fallback menu
├── themes/
│   └── nord.conf                  # Nord color theme
├── kittyvoncan/
│   └── custom.conf                # User customizations
└── backups/
    └── kittyvoncan-YYYYMMDD-HHMMSS/  # Backup directory
```

## Post-Installation

### Immediate Next Steps

1. **Restart kitty** or press **F5** to reload configuration
2. **Test context menu** by right-clicking in terminal
3. **Try F-key shortcuts** (F1 for nvim, F2 for ranger, etc.)
4. **Verify font rendering** - should show JetBrains Mono

### Configuration Testing

```bash
# Run comprehensive feature test
./tests/test_features.sh

# Validate configuration
./tests/validate_config.sh

# Quick functionality check
kitty @ load-config  # Should reload without errors
```

### First-Time Setup

1. **Open kitty** and verify the new appearance
2. **Right-click** to test context menu
3. **Press F1** to launch nvim (installs nvim if missing)
4. **Press F5** to test configuration reload
5. **Check font rendering** for ligatures and clarity

## Customization

### User Configuration

Edit your personal settings in `~/.config/kitty/kittyvoncan/custom.conf`:

```conf
# Example customizations
font_size 14.0
background_opacity 0.9
window_padding_width 8

# Custom shortcuts
map f13 launch --cwd=current code .
map ctrl+alt+g launch --cwd=current lazygit
```

### Theme Switching

```bash
# Switch to different theme (when available)
echo "include themes/solarized.conf" >> ~/.config/kitty/kitty.conf

# Or edit kitty.conf to change the include line
```

### Development Tool Configuration

Configure which tools F-keys launch by editing `kitty.conf`:

```conf
# Customize F-key bindings
map f1 launch --cwd=current vim        # Use vim instead of nvim
map f2 launch --cwd=current lf         # Use lf instead of ranger
map f3 launch --cwd=current btop       # Use btop instead of htop
```

## Troubleshooting Installation

### Common Issues

#### "kitty not found"
```bash
# Install kitty first
sudo apt install kitty  # Ubuntu/Debian
sudo dnf install kitty  # Fedora
sudo pacman -S kitty    # Arch
```

#### "Permission denied"
```bash
# Make installer executable
chmod +x install.sh
./install.sh
```

#### "Dependencies failed to install"
```bash
# Update package manager first
sudo apt update         # Ubuntu/Debian
sudo dnf makecache     # Fedora

# Try installing dependencies manually
sudo apt install xclip xdotool zenity
```

#### "Font installation failed"
```bash
# Install font manually
./config/scripts/install_deps.sh --fonts-only

# Or install system font package
sudo apt install fonts-jetbrains-mono  # If available
```

#### "Context menu doesn't work"
```bash
# Check dependencies
which xclip xdotool zenity

# Test script directly
~/.config/kitty/scripts/context_menu.sh

# Check X11/Wayland compatibility
echo $XDG_SESSION_TYPE
```

### Validation and Repair

```bash
# Validate installation
./tests/validate_config.sh

# Test all features interactively
./tests/test_features.sh

# Repair configuration
kitty --debug-config  # Shows configuration errors

# Reinstall if needed
./install.sh --force
```

### Getting Help

1. **Check validation output**: `./tests/validate_config.sh`
2. **Review kitty logs**: `kitty --debug-config`
3. **Test components individually**: Manual script execution
4. **Check GitHub issues**: Repository issue tracker
5. **Reinstall cleanly**: `./uninstall.sh && ./install.sh`

## Advanced Installation

### Silent/Automated Installation

For scripts and automated deployments:

```bash
# Completely automated installation
export AUTO_INSTALL=true
./install.sh --full --skip-prompts

# Or with environment variables
KITTYVONCAN_MINIMAL=true \
KITTYVONCAN_SKIP_FONTS=true \
./install.sh
```

### Multi-User Installation

```bash
# Install for current user (default)
./install.sh

# Install system-wide fonts (requires sudo)
sudo ./config/scripts/install_deps.sh --fonts-only

# Each user runs installer individually
# (kitty configs are per-user)
```

### Container/Docker Installation

```dockerfile
# Dockerfile example
FROM ubuntu:latest
RUN apt-get update && apt-get install -y kitty curl
USER developer
RUN curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

---

*For more help, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or open an issue on GitHub.*
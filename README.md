# KITTYVONCAN 🐱

**Professional Kitty Terminal Enhancement Package**

A comprehensive collection of quality-of-life improvements for the kitty terminal emulator, designed for developers and power users who demand a professional terminal experience.

## ✨ Features

### 🚀 Development-First Design
- **F1-F12 shortcuts** for instant access to development tools
- **Professional font integration** with JetBrains Mono and ligature support
- **Context menu system** with right-click functionality
- **Session management** tools for workflow optimization

### 🎨 Enhanced User Experience
- **Modern Nord theme** with professional color schemes
- **Advanced mouse mappings** including middle-click paste
- **Intelligent scrollback** configuration for better navigation
- **Professional cursor and visual settings**

### ⚡ Quick Access Tools
- **F1**: Smart Editor (Sublime Text → VS Code → Gedit → others)
- **F2**: Open Ranger file manager
- **F3**: System monitoring with htop
- **F4**: New window with current working directory
- **F5**: Reload configuration instantly
- **F7**: Git status overlay
- **F8**: New tab with current working directory
- **F12**: Quick shell overlay
- **Fabric dashboard**: Prebuilt accelerator cockpit via `fabric_dashboard.sh`

### 🔧 Professional Configuration
- **Font optimization** with advanced rendering features
- **Performance tuning** for smooth terminal operation
- **Advanced clipboard** integration with selection handling
- **Window and tab management** with professional layouts

## 🛠️ Installation

### Quick Install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/kittyvoncan/main/install.sh | bash
```

### Manual Installation
```bash
git clone https://github.com/YOUR_USERNAME/kittyvoncan.git
cd kittyvoncan
./install.sh
```

### Installation Options
```bash
./install.sh --help          # Show all options
./install.sh --minimal       # Core features only
./install.sh --full          # All features (default)
./install.sh --backup-only   # Backup existing config
./install.sh --restore       # Restore from backup
```

## 📋 Requirements

### Essential Dependencies
- **kitty** terminal emulator (v0.21.0+)
- **xclip** for clipboard operations
- **xdotool** for keyboard automation
- **zenity** for context menu dialogs

### Optional Dependencies
- **JetBrains Mono** font (auto-installed if needed)
- **rofi** for enhanced menus (fallback: zenity)
- **ranger** file manager (F2 shortcut)
- **htop** system monitor (F3 shortcut)
- **Text Editor** (F1 shortcut - auto-detects: Sublime Text, VS Code, Gedit, Kate, etc.)

## 🎯 Quick Start

After installation:

1. **Right-click** in terminal for context menu
2. **Press F1-F12** for development shortcuts
3. **Ctrl+Shift+M** for manual context menu
4. **Ctrl+Alt+S** for new session with current directory

### 📝 Smart Editor (F1)
The F1 key launches your best available text editor in this priority order:
1. **Sublime Text** (recommended)
2. **Visual Studio Code**
3. **Gedit** (GNOME default)
4. **Kate** (KDE editor)
5. **Atom** (GitHub)
6. **Mousepad** (lightweight)
7. **Vim/Neovim** (terminal)
8. **Nano** (fallback)

If no editor is found, a helpful dialog shows installation commands for popular editors.

## 📁 Package Structure

```
kittyvoncan/
├── install.sh              # Main installation script
├── uninstall.sh            # Clean uninstallation
├── config/                 # Configuration files
│   ├── kitty.conf          # Main kitty configuration
│   ├── nord.conf           # Nord theme
│   └── scripts/            # Helper scripts
│       ├── context_menu.sh # Context menu system
│       └── install_deps.sh # Dependency installer
├── fonts/                  # Font files
│   └── JetBrainsMono/      # JetBrains Mono fonts
├── themes/                 # Additional themes
├── tests/                  # Installation tests
└── docs/                   # Documentation
```

## 🔧 Configuration

KITTYVONCAN respects your existing kitty configuration by:
- **Backing up** your current `kitty.conf`
- **Merging** settings intelligently
- **Preserving** your custom keybindings
- **Allowing** selective feature installation

### Customization

Edit `~/.config/kitty/kittyvoncan/custom.conf` to add your personal settings.

## 🚨 Safety Features

- **Automatic backup** of existing configuration
- **Validation checks** before applying changes
- **Rollback capability** if installation fails
- **Non-destructive installation** preserves your setup

## 🧪 Testing

```bash
# Test installation without applying changes
./install.sh --dry-run

# Validate configuration
./tests/validate_config.sh

# Test all features
./tests/test_features.sh
```

### 🖥️ Fabric Dashboard (AI Fabric)

Spin up a multi-tab accelerator cockpit with:

```bash
~/.config/kitty/scripts/fabric_dashboard.sh
```

Layout includes fabric status, GPU/NPU monitors, OpenVINO bench, logs/metrics, and a dev tab. Adjust commands via environment variables (e.g., `KITTY_FABRIC_WORKDIR`, `FABRICCTL_CMD`, `OPENVINO_BENCH_CMD`) or edit the session template at `~/.config/kitty/kittyvoncan/sessions/fabric_dashboard.session`. See `docs/fabric_dashboard.md` for overrides and keybinding examples.

## 🔄 Uninstallation

```bash
# Simple uninstall
./uninstall.sh

# Complete removal with backup cleanup
./uninstall.sh --purge

# Restore original configuration
./uninstall.sh --restore-original
```

## 🐛 Troubleshooting

### Common Issues

**Context menu not working:**
```bash
# Check dependencies
./tests/check_deps.sh

# Test menu manually
~/.config/kitty/scripts/context_menu.sh
```

**F-keys not responding:**
```bash
# Reload configuration
kitty @ load-config
# Or press F5 in kitty
```

**Font issues:**
```bash
# Reinstall fonts
./config/scripts/install_deps.sh --fonts-only
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes thoroughly
4. Submit a pull request

## License

This project is licensed under the **SWORD Restricted Source Licence v1.1 (SRSL-1.1)**. Personal and non-commercial use is permitted under its terms; commercial exploitation requires a separate written agreement. See [LICENSE](LICENSE) and [migration notes](SRSL_MIGRATION.md). Previously issued SRSL-1.0 grants remain valid for their copies.

## 🙏 Acknowledgments

- **Kitty Terminal** - For the amazing terminal emulator
- **JetBrains** - For the excellent Mono font
- **Nord Theme** - For the beautiful color scheme
- **Community** - For feedback and contributions

---

**Made with ❤️ for terminal enthusiasts**

> Transform your kitty terminal into a professional development environment in minutes!

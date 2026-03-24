# QuickShell Bar

A modern, customizable desktop bar built with Quickshell and QML. This project provides a sleek, configurable status bar for Wayland compositors with extensive widget support and theming capabilities.

## Features

### 🎨 **Customizable Layout**

- **Multi-monitor support** - Automatically creates bars for all connected displays
- **Flexible positioning** - Top, bottom, left, or right bar placement
- **Dynamic widget arrangement** - Configure left, center, and right sections independently
- **Responsive design** - Adapts to both horizontal and vertical orientations

### 📱 **Rich Widget Ecosystem**

- **Workspaces** - Workspace switching and management
- **Window Title** - Active window title display
- **System Monitor** - CPU, memory, and system resource monitoring
- **Network** - Network connection status and statistics
- **Bluetooth** - Bluetooth device management
- **Battery** - Battery level and charging status
- **Audio** - Volume control and audio device management
- **Brightness** - Screen brightness adjustment
- **Night Shift** - Blue light filter control
- **Caffeine** - Prevent system sleep/hibernation
- **Clock** - Customizable clock with date display
- **System Tray** - System tray integration with menu support

### ⚙️ **Advanced Configuration**

- **Persistent state storage** - Settings automatically saved and restored
- **Real-time configuration** - Changes apply instantly without restart
- **Popup windows** - Interactive popups for detailed widget information
- **Animation system** - Smooth transitions and micro-interactions
- **Theme system** - Comprehensive theming with customizable colors and styles

## Architecture

```
quickshell-bar/
├── shell.qml              # Main entry point and window management
├── config/                # Configuration and theme management
│   ├── Config.qml         # Main configuration singleton
│   ├── Theme.qml          # Theme definitions
│   └── user_config.json   # User-specific settings
├── base/                  # Base components and utilities
│   ├── BaseComponent.qml  # Common component functionality
│   ├── BasePopup.qml      # Popup window base class
│   └── BaseWidget.qml     # Widget base class
├── components/            # Reusable UI components
│   ├── BarButton.qml      # Styled button component
│   ├── BarGraph.qml       # Graph visualization
│   ├── BarIcon.qml        # Icon display component
│   └── BarProgress.qml    # Progress bar component
├── services/              # System integration services
│   ├── AudioService.qml   # Audio system integration
│   ├── BatteryService.qml # Battery monitoring
│   ├── BluetoothService.qml # Bluetooth management
│   ├── NetworkService.qml # Network monitoring
│   └── StateStore.qml     # Persistent state management
├── widgets/               # Widget implementations
│   └── bar/               # Bar-specific widgets
│       ├── Audio.qml
│       ├── Battery.qml
│       ├── Clock.qml
│       ├── Network.qml
│       └── ...
└── types/                 # Type definitions and interfaces
```

## Quick Start

### Prerequisites

- Quickshell runtime environment
- Wayland compositor (e.g., Sway, Hyprland, GNOME Wayland)
- Qt 6.0 or later

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd quickshell-bar
   ```

2. **Configure Quickshell**
   - Add the project path to your Quickshell configuration
   - Ensure Wayland integration is enabled

3. **Launch the bar**
   ```bash
   quickshell shell.qml
   ```

## Configuration

### Basic Settings

Edit `config/user_config.json` or use the configuration interface:

```json
{
  "widgets": {
    "bar": {
      "config": {
        "position": 0, // 0=Top, 1=Bottom, 2=Left, 3=Right
        "barSize": 32, // Bar height/width in pixels
        "barMargin": 0, // Margin from screen edge
        "barRadius": 8, // Corner radius
        "showClock": true, // Widget visibility toggles
        "showAudio": true,
        "showNetwork": true,
        "animationDuration": 150, // Animation speed
        "popupWidth": 320, // Popup window dimensions
        "popupHeight": 400
      }
    }
  }
}
```

### Widget Layout

Configure widget arrangement for each section:

```json
{
  "layoutLeft": ["workspaces", "windowTitle"],
  "layoutCenter": [],
  "layoutRight": [
    "systemMonitor",
    "network",
    "bluetooth",
    "battery",
    "audio",
    "clock"
  ]
}
```

### Theming

Customize colors and appearance in `config/Theme.qml`:

```qml
readonly property color bg: "#1a1a1a"
readonly property color widgetBg: "#2a2a2a"
readonly property color fg: "#ffffff"
readonly property color accent: "#4a9eff"
```

## Widget Reference

### System Widgets

- **Workspaces**: Navigate between virtual desktops
- **SystemMonitor**: Display CPU, memory, and system stats
- **Network**: Show connection status and bandwidth usage
- **Battery**: Monitor battery level and charging state
- **Audio**: Control volume and switch audio devices
- **Brightness**: Adjust screen brightness
- **Bluetooth**: Manage Bluetooth connections
- **Clock**: Display current time and date

### Utility Widgets

- **WindowTitle**: Show active window title
- **NightShift**: Toggle blue light filter
- **Caffeine**: Prevent automatic screen lock/sleep
- **Tray**: System tray with application icons

## Development

### Adding New Widgets

1. Create widget QML file in `widgets/bar/`
2. Inherit from `BaseWidget` for consistent functionality
3. Implement required properties and methods
4. Add widget to configuration options

Example widget structure:

```qml
pragma ComponentBehavior: Bound
import QtQuick
import "../../base" as Base
import "../../services" as Services

Base.BaseWidget {
    id: root

    // Widget implementation
    Text {
        text: "My Widget"
        color: Config.Theme.fg
    }
}
```

### Services Integration

Access system services through the services module:

```qml
import "../../services" as Services

// Use services
property var audioService: Services.AudioService
property var batteryService: Services.BatteryService
```

### State Management

All configuration changes are automatically persisted through the StateStore service. Properties bound to `storeConfig` will be saved and restored automatically.

## Customization

### Creating Themes

1. Copy `config/Theme.qml` to a new theme file
2. Modify color properties and styling
3. Update `Config.qml` to reference your theme
4. Restart or reload configuration

### Widget Configuration

Each widget can have individual configuration:

```json
{
  "clockConfig": {
    "format24h": true,
    "showSeconds": false,
    "dateFormat": "YYYY-MM-DD"
  },
  "audioConfig": {
    "showVolumePercentage": true,
    "stepSize": 5
  }
}
```

## Troubleshooting

### Common Issues

**Bar not appearing**

- Check Quickshell installation and Wayland support
- Verify shell.qml path in Quickshell configuration
- Check system logs for error messages

**Widgets not loading**

- Ensure required system services are running
- Check widget visibility settings in configuration
- Verify widget files exist in correct locations

**Configuration not saving**

- Check StateStore service initialization
- Verify write permissions for config directory
- Ensure configuration JSON syntax is valid

### Debug Mode

Enable debug output by setting environment variable:

```bash
QML_DEBUG=1 quickshell shell.qml
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Test thoroughly
5. Submit a pull request

### Code Style

- Follow QML naming conventions
- Use meaningful component and property names
- Add comments for complex logic
- Ensure consistent indentation

## License

This project is licensed under the No AI License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Quickshell framework for the runtime environment
- Qt/QML for the UI framework
- Wayland for compositor integration
- Community contributors and feedback
- [Noctalia](https://github.com/noctalia-dev/noctalia-shell)
- [Caelestia](https://github.com/caelestia-dots/shell)

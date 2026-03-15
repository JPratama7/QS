pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Color Palette (Tokyo Night inspired)
    property color bg: "#1a1b26"
    property color bgBright: "#24283b"
    property color bgDark: "#16161e"
    property color fg: "#c0caf5"
    property color fgBright: "#ffffff"
    property color fgDark: "#565f89"
    property color fgMuted: "#414868"

    // Accent Colors
    property color accent: "#7aa2f7"
    property color accentBright: "#a9b1d6"
    property color accentDark: "#3d59a1"
    property color accentMuted: "#565f89"

    // Semantic Colors
    property color success: "#9ece6a"
    property color warning: "#e0af68"
    property color error: "#f7768e"
    property color info: "#7dcfff"
    property color purple: "#bb9af7"
    property color green: "#73daca"
    property color yellow: "#ff9e64"
    property color cyan: "#7dcfff"

    // Widget Colors
    property color widgetBg: bgBright
    property color widgetBgHover: "#3d4266"
    property color widgetBgActive: accentDark
    property color widgetBorder: fgMuted
    property color widgetBorderActive: accent

    // Popup Colors
    property color popupBg: bg
    property color popupBorder: fgMuted
    property color popupShadow: "#000000"

    // Text Colors
    property color textPrimary: fg
    property color textSecondary: fgDark
    property color textMuted: fgMuted
    property color textAccent: accent

    // Icon Colors
    property color iconPrimary: fg
    property color iconSecondary: fgDark
    property color iconAccent: accent

    // Graph/Chart Colors
    property color graphCpu: accent
    property color graphRam: purple
    property color graphTemp: warning
    property color graphNetwork: cyan
    property color graphBackground: bgDark

    // Typography
    property string fontFamily: "JetBrainsMono Nerd Font, JetBrains Mono, monospace"
    property int fontSizeXSmall: 8
    property int fontSizeSmall: 10
    property int fontSizeNormal: 11
    property int fontSizeLarge: 13
    property int fontSizeXLarge: 15

    // Sizing
    property int componentSize: 20
    property int iconSize: 14
    property int iconSizeLarge: 18
    property int spacing: 4
    property int spacingLarge: 6
    property int padding: 6
    property int paddingLarge: 10
    property int borderRadius: 100
    property int borderRadiusLarge: 100

    // Bar Specific
    property int barPadding: 2
    property int barSpacing: 4
    property int widgetPadding: 6
    property int widgetSpacing: 4

    // Opacity
    property real opacityNormal: 1.0
    property real opacityHover: 1.0
    property real opacityDisabled: 0.5
    property real opacityMuted: 0.7

    // Animation Durations (in ms)
    property int animationFast: 100
    property int animationNormal: 150
    property int animationSlow: 250

    // Shadows
    property color shadowColor: "#000000"
    property real shadowOpacity: 0.3
    property int shadowRadius: 8
    property int shadowOffset: 2

    // Helper function to get workspace color based on state
    function getWorkspaceColor(active: bool, focused: bool, urgent: bool): color {
        if (urgent) return error
        if (focused) return accent
        if (active) return accentBright
        return fgMuted
    }

    // Helper function to get battery color based on percentage
    function getBatteryColor(percentage: int, charging: bool): color {
        if (charging) return success
        if (percentage <= 20) return error
        if (percentage <= 50) return warning
        return success
    }

    // Helper function to get volume color based on level
    function getVolumeColor(level: int, muted: bool): color {
        if (muted) return fgMuted
        if (level <= 30) return fgDark
        if (level <= 70) return accent
        return warning
    }

    // Helper function to get brightness color
    function getBrightnessColor(level: int): color {
        if (level <= 30) return warning
        return yellow
    }

    // Helper function to get network signal color
    function getSignalColor(strength: int): color {
        if (strength <= 25) return error
        if (strength <= 50) return warning
        if (strength <= 75) return accent
        return success
    }
}

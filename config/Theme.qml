import QtQml
import QtQuick
pragma Singleton

QtObject {
    id: theme

    // Colors
    readonly property color backgroundColor: "#1e1e2e"
    readonly property color foregroundColor: "#cdd6f4"
    readonly property color accentColor: "#89b4fa"
    readonly property color mutedColor: "#6c7086"
    readonly property color surfaceColor: "#313244"
    readonly property color errorColor: "#f38ba8"
    // Typography
    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 15
    // Icon sizes
    readonly property int iconSizeSmall: 16
    // Spacing
    readonly property int paddingSmall: 4
    readonly property int paddingNormal: 8
    readonly property int paddingLarge: 12
    readonly property int spacingSmall: 4
    readonly property int spacingNormal: 8
    readonly property int spacingLarge: 16
    // Radii
    readonly property int radiusSmall: 4
    readonly property int radiusNormal: 8
    readonly property int radiusLarge: 12
}

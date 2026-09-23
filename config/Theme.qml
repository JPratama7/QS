import QtQml
import QtQuick
pragma Singleton

QtObject {
    id: theme

    // Active palette — resolved from config, falls back to deepMocha
    readonly property var _palette: ShellConfig.activePalette

    // Colors — derived from the active palette
    readonly property color backgroundColor: _palette.background
    readonly property color foregroundColor: _palette.foreground
    readonly property color accentColor: _palette.accent
    readonly property color mutedColor: _palette.muted
    readonly property color surfaceColor: _palette.surface
    readonly property color errorColor: _palette.error
    // Bar-specific colors — Mantle (darker than base) for depth against windows
    readonly property color barBackgroundColor: _palette.barBackground
    readonly property color hoverColor: Qt.alpha(foregroundColor, 0.08)
    readonly property color hoverAccentColor: Qt.alpha(accentColor, 0.15)
    readonly property color borderColor: Qt.alpha(foregroundColor, 0.08)

    // Glass tokens — all derived from palette colors, no new hues (DESIGN_GUIDE.md)
    // Opacity driven by the transparency config (bar / popup percent)
    readonly property color glassBackground: Qt.alpha(barBackgroundColor, ShellConfig.barOpacity)
    readonly property color glassSurface: Qt.alpha(surfaceColor, ShellConfig.popupOpacity)
    readonly property color glassBorder: Qt.alpha(foregroundColor, 0.06)
    readonly property color accentSoft: Qt.alpha(accentColor, 0.13)
    readonly property color accentBorder: Qt.alpha(accentColor, 0.35)
    readonly property color dangerSoft: Qt.alpha(errorColor, 0.15)
    readonly property color dangerBorder: Qt.alpha(errorColor, 0.35)

    // Typography
    readonly property string fontFamily: "sans-serif"
    readonly property string fontFamilyMono: "monospace"
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
    // Glass radii (DESIGN_GUIDE.md)
    readonly property int radiusGlassy: 16
    readonly property int radiusInner: 12
    readonly property int radiusPill: 999
    readonly property int listHighlightDuration: 150
    // Widget hover transition
    readonly property int hoverDuration: 120
}

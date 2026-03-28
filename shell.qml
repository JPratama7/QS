pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "config" as Config
import "widgets/bar" as BarWidgets

// Main shell configuration
Scope {
    id: root

    // Force Config initialization early
    readonly property var config: Config.Config

    Component.onCompleted: {
        Qt.application.name = "QuickshellBar";
        Qt.application.organization = "Quickshell";
        Qt.application.domain = "quickshell.org";
    }

    // Variants for multi-monitor support
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property var screen: modelData

            implicitHeight: Config.Config.isHorizontal ? Config.Config.barSize : 0
            implicitWidth: Config.Config.isVertical ? Config.Config.barSize : 0
            color: Config.Theme.bg
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Config.Config.barSize

            // Position based on config
            anchors {
                top: Config.Config.position === Config.Config.Position.Top || Config.Config.isVertical
                bottom: Config.Config.position === Config.Config.Position.Bottom || Config.Config.isVertical
                left: Config.Config.position === Config.Config.Position.Left || Config.Config.isHorizontal
                right: Config.Config.position === Config.Config.Position.Right || Config.Config.isHorizontal
            }

            // Main bar content
            BarWidgets.Bar {
                screen: bar.screen
            }

        }

    }

}

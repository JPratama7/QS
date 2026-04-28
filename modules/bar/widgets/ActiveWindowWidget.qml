pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../services/system"
import "../../../config"
import "../../../components/bar"

import Quickshell.Widgets

BaseWidget {
    id: widget

    required property string screenName

    tooltipComponent: Component {
        Text {
            text: widget.windowTitle || "No active window"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
        }
    }

    property var activeWindow: null
    readonly property string windowTitle: activeWindow ? activeWindow.title : ""
    property int maxTextWidth: 200

    function applyActiveWindowConfig(): void {
        const widgetsConfig = ShellConfig.barWidgetsConfig()
        const activeWindowConfig = widgetsConfig.activeWindow || {}
        const configuredMaxTextWidth = activeWindowConfig.maxTextWidth

        maxTextWidth = (typeof configuredMaxTextWidth === "number" && configuredMaxTextWidth > 0)
            ? configuredMaxTextWidth
            : Defaults.bar.widgets.activeWindow.maxTextWidth
    }

    Component.onCompleted: applyActiveWindowConfig()

    Connections {
        target: Compositor
        function onActiveToplevelChanged(data: var){
            widget.activeWindow = data;
        }
    }

    Connections {
        target: ShellConfig
        function onBarChanged(): void {
            widget.applyActiveWindowConfig()
        }
    }


    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: Theme.spacingSmall

        IconImage {
            width: Theme.iconSizeSmall
            height: Theme.iconSizeSmall
            source: AppIcons.iconForAppId(widget.activeWindow?.appId ?? "")
        }

        Text {
            id: text
            text: widget.windowTitle || "No active window"
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.foregroundColor
            elide: Text.ElideRight
            width: widget.maxTextWidth
        }
    }
}

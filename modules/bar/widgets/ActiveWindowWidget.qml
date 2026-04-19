pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../services/system"
import "../../../config"

import Quickshell.Widgets

Item {
    id: widget

    required property string screenName

    property var activeWindow: null
    readonly property string windowTitle: activeWindow ? activeWindow.title : ""

    Connections {
        target: Compositor
        function onActiveToplevelChanged(data: var){
            widget.activeWindow = data;
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
            width: 200
        }
    }
}

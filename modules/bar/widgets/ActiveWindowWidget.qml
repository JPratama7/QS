pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/compositor"
import "../../../config"

Item {
    id: widget

    required property string screenName

    readonly property var activeWindow: Compositor.activeWindowForScreen(screenName)
    readonly property string windowTitle: activeWindow ? activeWindow.title : ""

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight

    Text {
        id: text
        text: widget.windowTitle || "No active window"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.foregroundColor
        elide: Text.ElideRight
        width: 200
    }
}

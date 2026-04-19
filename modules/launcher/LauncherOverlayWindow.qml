pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/launcher"

PanelWindow {
    id: overlay

    required property string screenName

    function reset(): void {
        launcherView.reset();
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: Qt.alpha(Theme.backgroundColor, 0.85)

    visible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-launcher-" + overlay.screenName
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Click-outside-to-close
    MouseArea {
        anchors.fill: parent
        onClicked: Launcher.close()
    }

    // Centered launcher view
    LauncherView {
        id: launcherView
        anchors.centerIn: parent
        width: 500
        height: Math.min(implicitHeight, parent.height - 100)
    }

    onVisibleChanged: {
        if (!visible) {
            Launcher.close();
        }
    }
}

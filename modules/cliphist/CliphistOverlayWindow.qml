pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/system"

PanelWindow {
    id: overlay

    required property string screenName

    function reset(): void {
        cliphistView.reset();
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
    WlrLayershell.namespace: "qs-cliphist-" + overlay.screenName
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Click-outside-to-close
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: mouse => {
            const viewRect = mapFromItem(cliphistView, 0, 0);
            const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + cliphistView.width ||
                            mouse.y < viewRect.y || mouse.y > viewRect.y + cliphistView.height);
            if (outside) {
                Cliphist.close();
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }
    }

    // Centered cliphist view
    CliphistView {
        id: cliphistView
        anchors.centerIn: parent
        width: 500
        height: Math.min(implicitHeight, parent.height - 100)
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/ui"

PanelWindow {
    id: overlay

    required property string screenName

    function reset(): void {
        settingsView.reset();
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
    WlrLayershell.namespace: "qs-settings-" + overlay.screenName
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Click-outside-to-close
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: (mouse) => {
            const viewRect = mapFromItem(settingsView, 0, 0);
            const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + settingsView.width ||
                            mouse.y < viewRect.y || mouse.y > viewRect.y + settingsView.height);
            if (outside) {
                ShellUI.closeSettings();
                mouse.accepted = false; // Pass through to underlying window
            } else {
                mouse.accepted = true; // Consume clicks inside
            }
        }
    }

    // Centered view
    SettingsView {
        id: settingsView
        anchors.centerIn: parent
        width: 600
        height: Math.min(implicitHeight, parent.height - 100)
    }
}

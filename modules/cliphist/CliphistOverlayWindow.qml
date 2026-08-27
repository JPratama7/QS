pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/system"

PanelWindow {
    id: overlay

    required property string screenName

    // `shown` is the visual state the transition binds to. The window's `visible`
    // stays true during the close animation so the exit can render; `shown` flips
    // false to drive the exit, and the loader is torn down only after `closed`.
    property bool shown: false
    property bool closing: false

    signal closed

    function reset(): void {
        cliphistView.reset();
    }

    // Play the exit transition, then emit `closed` so the owner can drop the loader.
    function closeAnimated(): void {
        if (overlay.closing)
            return;
        overlay.closing = true;
        overlay.shown = false;
        closeTimer.restart();
    }

    // Cancel an in-progress close when cliphist is re-opened mid-transition.
    function abortClose(): void {
        closeTimer.stop();
        overlay.closing = false;
        overlay.shown = true;
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    visible: false
    color: overlay.shown ? Qt.alpha(Theme.backgroundColor, 0.85) : Qt.rgba(0, 0, 0, 0)
    Behavior on color {
        ColorAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs-cliphist-" + overlay.screenName
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    onVisibleChanged: {
        // Window just became visible -> play the open animation.
        if (overlay.visible && !overlay.closing)
            overlay.shown = true;
    }

    Timer {
        id: closeTimer

        interval: 220
        repeat: false

        onTriggered: overlay.closed()
    }

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

        // Open: opacity 0->1, scale 0.96->1.0. Close reverses via `shown`.
        opacity: overlay.shown ? 1 : 0
        scale: overlay.shown ? 1 : 0.96
        transformOrigin: Item.Center

        Behavior on opacity {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }
}

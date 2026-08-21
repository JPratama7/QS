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
        emojiView.reset();
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
    WlrLayershell.namespace: "qs-emoji-" + overlay.screenName
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    // Click-outside-to-close
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: mouse => {
            const viewRect = mapFromItem(emojiView, 0, 0);
            const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + emojiView.width ||
                            mouse.y < viewRect.y || mouse.y > viewRect.y + emojiView.height);
            if (outside) {
                Emoji.close();
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }
    }

    // Centered emoji view
    EmojiView {
        id: emojiView
        anchors.centerIn: parent
        width: 500
        height: Math.min(implicitHeight, parent.height - 100)
    }
}

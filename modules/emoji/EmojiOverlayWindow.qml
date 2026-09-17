pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/system"
import "../search"

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
    SearchView {
        id: emojiView
        anchors.centerIn: parent
        width: 500
        height: Math.min(implicitHeight, parent.height - 100)
        searchService: Emoji
        resultDelegate: emojiResultDelegate
        placeholderText: "Search emoji..."
    }

    Component {
        id: emojiResultDelegate

        Rectangle {
            id: resultRow
            required property var modelData
            required property int index

            width: parent.width
            height: glyphText.implicitHeight + Theme.paddingSmall * 2
            radius: Theme.radiusSmall
            color: resultRow.index === Emoji.selectedIndex
                ? Qt.alpha(Theme.accentColor, 0.15)
                : "transparent"

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }
                spacing: Theme.spacingSmall

                Text {
                    id: glyphText
                    width: 36
                    text: resultRow.modelData.c
                    font.pixelSize: 24          // larger than Theme.fontSizeLarge (15)
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.foregroundColor
                }
                Text {
                    width: parent.width - glyphText.width - parent.spacing
                    text: resultRow.modelData.n
                    color: Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: Emoji.selectedIndex = resultRow.index
                onClicked: {
                    Emoji.selectedIndex = resultRow.index;
                    Emoji.activateSelected();
                }
            }
        }
    }
}

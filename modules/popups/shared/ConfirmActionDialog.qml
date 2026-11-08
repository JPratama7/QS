pragma ComponentBehavior: Bound

import QtQuick
import "../../../config"

// Scrim-over-card confirm flow — the card swaps content, no new window
// (DESIGN_GUIDE.md §6): glass card, danger button for destructive actions.
Rectangle {
    id: dialog

    property string action: ""
    property string confirmLabel: "Confirm"

    signal confirmed()
    signal cancelled()

    color: Qt.rgba(0, 0, 0, 0.4)

    MouseArea {
        anchors.fill: parent
        onClicked: dialog.cancelled()
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: parent.width - Theme.paddingLarge * 2
        height: contentColumn.implicitHeight + Theme.paddingLarge * 2
        color: Theme.glassSurface
        radius: Theme.radiusGlassy
        border.width: 1
        border.color: Theme.glassBorder

        Column {
            id: contentColumn

            anchors.centerIn: parent
            spacing: Theme.spacingNormal
            width: parent.width - Theme.paddingNormal * 2

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: dialog.action + "?"
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "Unsaved work in running apps will be lost."
                color: Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingSmall

                // Cancel — neutral glass button
                Rectangle {
                    width: 96
                    height: confirmLabel.implicitHeight + Theme.paddingNormal * 2
                    radius: Theme.radiusInner
                    color: cancelArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.1) : Qt.alpha(Theme.foregroundColor, 0.05)
                    border.width: 1
                    border.color: Theme.glassBorder

                    Text {
                        id: cancelLabel
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dialog.cancelled()
                    }
                }

                // Confirm — solid danger
                Rectangle {
                    width: 96
                    height: confirmLabel.implicitHeight + Theme.paddingNormal * 2
                    radius: Theme.radiusInner
                    color: Theme.errorColor

                    Text {
                        id: confirmLabel
                        anchors.centerIn: parent
                        text: dialog.confirmLabel
                        color: Theme.barBackgroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: confirmArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dialog.confirmed()
                    }
                }
            }
        }
    }

    // Esc cancels
    Keys.onEscapePressed: dialog.cancelled()
    focus: true
}

pragma ComponentBehavior: Bound

import QtQuick
import "../../../components"
import "../../../config"

// Compact slider row for the control center: icon + glowing track + value.
// The consumer binds `value` to its service; dragging emits `changed` with the
// dragged fraction. The visual follows the drag while pressed, then snaps to
// the (service-confirmed) `value` — so external updates re-render correctly
// without fighting the consumer's binding.
Item {
    id: slider

    property string iconSource: ""
    property color iconColor: Theme.mutedColor
    property bool iconClickable: false
    property real value: 0
    property string valueText: ""
    signal changed(real value)
    signal iconClicked()

    property real _dragValue: 0
    property bool _dragging: false

    // Fixed 28px touch row — icon chip, track, and value all share it
    implicitHeight: 28
    implicitWidth: parent.width

    Row {
        id: row

        width: parent.width
        height: 28
        spacing: Theme.spacingNormal

        Item {
            id: iconHost

            width: 24
            height: parent.height

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusInner
                color: iconArea.containsMouse ? Theme.accentSoft : "transparent"
            }
            SvgIcon {
                id: icon

                anchors.centerIn: parent
                source: slider.iconSource
                iconSize: 17
                color: slider.iconColor
            }
            MouseArea {
                id: iconArea

                anchors.fill: parent
                hoverEnabled: true
                enabled: slider.iconClickable
                cursorShape: Qt.PointingHandCursor

                onClicked: slider.iconClicked()
            }
        }
        Item {
            id: trackHost

            width: parent.width - iconHost.width - valueLabel.width - parent.spacing * 2
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                radius: height / 2
                color: Qt.alpha(Theme.foregroundColor, 0.1)
            }
            Rectangle {
                id: fill

                anchors.verticalCenter: parent.verticalCenter
                width: track.width * (slider._dragging ? slider._dragValue : slider.value)
                height: 6
                radius: height / 2
                color: Theme.accentColor
            }
            Rectangle {
                id: knob

                width: 15
                height: 15
                radius: width / 2
                color: Theme.foregroundColor
                x: fill.width - width / 2
                anchors.verticalCenter: parent.verticalCenter
            }
            MouseArea {
                id: dragArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateFromMouse(mouse: var): void {
                    slider._dragValue = Math.max(0, Math.min(1, mouse.x / dragArea.width));
                }

                onPressed: mouse => {
                    slider._dragging = true;
                    dragArea.updateFromMouse(mouse);
                }
                onPositionChanged: mouse => {
                    if (slider._dragging)
                        dragArea.updateFromMouse(mouse);
                }
                onReleased: mouse => {
                    if (!slider._dragging)
                        return;
                    slider._dragging = false;
                    dragArea.updateFromMouse(mouse);
                    slider.changed(slider._dragValue);
                }
            }
        }
        Text {
            id: valueLabel

            text: slider.valueText
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall - 1
            font.family: Theme.fontFamilyMono
            horizontalAlignment: Text.AlignRight
            width: 32
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

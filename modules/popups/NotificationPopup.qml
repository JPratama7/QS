pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications as QuickshellNotifications
import "../../config"
import "../../services/system"

Item {
    id: root

    required property string screenName

    readonly property int popupWidth: 280
    readonly property int maxPopupHeight: 400

    implicitWidth: popupWidth
    implicitHeight: Math.min(column.implicitHeight + Theme.paddingNormal * 2, maxPopupHeight)

    Rectangle {
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Column {
        id: column
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingSmall

        // Header
        Text {
            width: parent.width
            text: "Notifications"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
            font.weight: Font.Medium
        }

        // Clear all button (only show if there are notifications)
        Button {
            id: clearAllButton
            width: parent.width
            height: clearAllText.implicitHeight + Theme.paddingSmall * 2
            visible: Notification.trackedList.length > 0

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: clearAllArea.containsMouse ? Qt.alpha(Theme.errorColor, 0.15) : "transparent"
            }

            Text {
                id: clearAllText
                anchors.centerIn: parent
                text: "Clear All"
                color: clearAllArea.containsMouse ? Theme.errorColor : Theme.mutedColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
            }

            MouseArea {
                id: clearAllArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Notification.dismissAll()
            }
        }

        // Notifications list
        ScrollView {
            id: notificationsScrollView

            width: parent.width
            height: Math.min(notificationColumn.implicitHeight, root.maxPopupHeight - clearAllButton.height - 30 - Theme.paddingNormal * 4)
            visible: Notification.trackedList.length > 0
            clip: true

            Column {
                id: notificationColumn
                width: parent.width
                spacing: Theme.spacingSmall

                Repeater {
                    model: Notification.trackedList

                    delegate: Item {
                        id: notificationItem

                        required property QuickshellNotifications.Notification modelData
                        property QuickshellNotifications.Notification notification: modelData

                        readonly property int itemPadding: Theme.paddingSmall
                        readonly property int iconSize: Theme.iconSizeSmall * 1.5

                        width: notificationColumn.width
                        implicitHeight: contentColumn.implicitHeight + itemPadding * 2

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSmall
                            color: itemArea.containsMouse ? Qt.alpha(Theme.foregroundColor, 0.05) : "transparent"
                        }

                        Row {
                            id: contentColumn
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                                margins: notificationItem.itemPadding
                            }
                            spacing: Theme.spacingSmall

                            Rectangle {
                                id: iconContainer
                                width: notificationItem.iconSize
                                height: width
                                radius: Theme.radiusSmall
                                color: Qt.alpha(Theme.accentColor, 0.2)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "🔔"
                                    font.pixelSize: Theme.iconSizeSmall
                                    color: Theme.accentColor
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - iconContainer.width - parent.spacing - dismissButton.width

                                Text {
                                    id: titleText
                                    width: parent.width
                                    text: notificationItem.notification.summary || "Notification"
                                    color: Theme.foregroundColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: Theme.fontFamily
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                Text {
                                    id: bodyText
                                    width: parent.width
                                    text: notificationItem.notification.body || ""
                                    color: Theme.mutedColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                    maximumLineCount: 3
                                    wrapMode: Text.WordWrap
                                    visible: text.length > 0
                                }
                            }

                            MouseArea {
                                id: dismissButton
                                z: 1 // Need to above MouseArea for itemArea
                                width: Theme.iconSizeSmall + Theme.paddingSmall
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                hoverEnabled: true

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.radiusSmall
                                    color: dismissButton.containsMouse ? Qt.alpha(Theme.errorColor, 0.2) : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: dismissButton.containsMouse ? Theme.errorColor : Theme.mutedColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: Theme.fontFamily
                                }

                                onClicked: {
Notification.dismiss(notificationItem.notification);
                                }
                            }
                        }

                        MouseArea {
                            id: itemArea
                            z: -1 // Need to be below dismiss button to not block clicks
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Notification.dismiss(notificationItem.notification);
                            }
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            width: parent.width
            text: "No notifications"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            horizontalAlignment: Text.AlignHCenter
            visible: Notification.trackedList.length === 0
        }
    }
}

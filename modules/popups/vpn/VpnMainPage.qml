pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"

Item {
    id: page

    required property string screenName
    required property StackView stackView

    signal importRequested()

    readonly property int maxMenuHeight: ShellConfig.trayMenuMaxHeight
    readonly property int contentHeight: pageColumn.implicitHeight + Theme.paddingNormal * 2

    implicitWidth: width
    implicitHeight: Math.min(contentHeight, maxMenuHeight)

    Component.onCompleted: Vpn.refresh()

    ScrollView {
        contentHeight: pageColumn.implicitHeight + Theme.paddingNormal
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Theme.paddingNormal
        }

        Column {
            id: pageColumn
            spacing: 2
            anchors {
                left: parent.left
                right: parent.right
            }

            Rectangle {
                width: pageColumn.width
                height: uploadLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: uploadArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

                Row {
                    spacing: Theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.paddingSmall
                    SvgIcon {
                        source: "icons/outline/upload.svg"
                        color: Theme.foregroundColor
                        iconSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: uploadLabel
                        text: "Upload configuration files"
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: uploadArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: page.importRequested()
                }
            }

            Repeater {
                model: Vpn.configNames
                delegate: Rectangle {
                    id: configRow
                    required property var modelData
                    width: pageColumn.width
                    height: configLabel.implicitHeight + Theme.paddingSmall * 2
                    radius: Theme.radiusSmall
                    color: configArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

                    Row {
                        spacing: Theme.spacingSmall
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: Theme.paddingSmall
                        SvgIcon {
                            source: "icons/outline/check.svg"
                            color: Theme.accentColor
                            iconSize: Theme.fontSizeSmall
                            visible: Vpn.isConnected(configRow.modelData)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            id: configLabel
                            text: configRow.modelData
                            color: Theme.foregroundColor
                            font.pixelSize: Theme.fontSizeSmall
                            font.family: Theme.fontFamily
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: configArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: page.stackView.push(Qt.resolvedUrl("VpnActionPage.qml"), {
                            name: configRow.modelData,
                            screenName: page.screenName,
                            stackView: page.stackView,
                            width: page.width
                        })
                    }
                }
            }

            Rectangle {
                width: pageColumn.width
                height: disconnectAllLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                visible: Vpn.connectedCount > 0
                color: disconnectAllArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

                Row {
                    spacing: Theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.paddingSmall
                    SvgIcon {
                        source: "icons/outline/player-stop.svg"
                        color: Theme.foregroundColor
                        iconSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: disconnectAllLabel
                        text: "Disconnect all"
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: disconnectAllArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Vpn.disconnectAll();
                        ShellUI.closePopup(page.screenName);
                    }
                }
            }
        }
    }
}

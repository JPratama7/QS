pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../shared"

Item {
    id: page

    required property string name
    required property string screenName
    required property StackView stackView

    property bool _confirmDialog: false
    property string _pendingLabel: ""

    readonly property int maxMenuHeight: ShellConfig.trayMenuMaxHeight
    readonly property int headerHeight: backButton.height + Theme.spacingSmall
    readonly property int contentHeight: headerHeight + pageColumn.implicitHeight + Theme.paddingNormal * 2

    implicitWidth: width
    implicitHeight: Math.min(contentHeight, headerHeight + maxMenuHeight)

    function openDialog(label: string) {
        page._confirmDialog = true;
        page._pendingLabel = label;
    }
    function closeDialog() {
        page._confirmDialog = false;
        page._pendingLabel = "";
    }

    Rectangle {
        id: backButton
        height: backRow.implicitHeight + Theme.paddingSmall * 2
        radius: Theme.radiusSmall
        color: backArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.paddingNormal
            leftMargin: Theme.paddingNormal
            rightMargin: Theme.paddingNormal
        }
        Row {
            id: backRow
            spacing: Theme.spacingSmall
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: Theme.paddingSmall
            }
            SvgIcon {
                source: "icons/outline/chevron-left.svg"
                color: Theme.accentColor
                iconSize: Theme.fontSizeSmall
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "Back"
                color: Theme.accentColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: backArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: page.stackView.pop()
        }
    }

    ScrollView {
        contentHeight: pageColumn.implicitHeight + Theme.paddingNormal
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        anchors {
            top: backButton.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: Theme.spacingSmall
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
                height: connectLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: connectArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

                Row {
                    spacing: Theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.paddingSmall
                    SvgIcon {
                        source: Vpn.isConnected(page.name) ? "icons/outline/player-stop.svg" : "icons/outline/plug.svg"
                        color: Theme.foregroundColor
                        iconSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: connectLabel
                        text: Vpn.isConnected(page.name) ? "Disconnect" : "Connect"
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: connectArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (Vpn.isConnected(page.name)) {
                            // Fast sudo -n path; root catches elevationRequired
                            // and pushes the password page if the cache is stale.
                            Vpn.disconnect(page.name);
                        } else {
                            page.stackView.push(Qt.resolvedUrl("VpnPasswordPage.qml"), {
                                title: "Enter the sudo password to connect",
                                name: page.name,
                                mode: "connect",
                                action: null,
                                stackView: page.stackView,
                                screenName: page.screenName,
                                width: page.width
                            });
                        }
                    }
                }
            }

            Rectangle {
                width: pageColumn.width
                height: deleteLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: deleteArea.containsMouse ? Qt.alpha(Theme.errorColor, 0.15) : "transparent"

                Row {
                    spacing: Theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.paddingSmall
                    SvgIcon {
                        source: "icons/outline/trash.svg"
                        color: Theme.errorColor
                        iconSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: deleteLabel
                        text: "Delete"
                        color: Theme.errorColor
                        font.pixelSize: Theme.fontSizeSmall
                        font.family: Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: deleteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: page.openDialog("delete " + page.name)
                }
            }
        }
    }

    ConfirmActionDialog {
        anchors.fill: parent
        visible: page._confirmDialog
        action: "Are you sure you want to " + page._pendingLabel
        onConfirmed: {
            Vpn.deleteConfig(page.name);
            page.closeDialog();
        }
        onCancelled: page.closeDialog()
    }
}

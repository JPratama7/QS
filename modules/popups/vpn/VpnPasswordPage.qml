pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../config"
import "../../../services/system"
import "../../../services/ui"

Item {
    id: page

    property string title: ""
    property string name: ""
    property string mode: "connect"
    property var action: null
    required property StackView stackView
    required property string screenName

    implicitWidth: width
    implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

    function submit(): void {
        const pwd = passwordInput.text;
        passwordInput.text = ""; // clear immediately (plan §7)
        if (page.mode === "connect")
            Vpn.connect(page.name, pwd);
        else if (page.action !== null)
            Vpn.supplyPassword(page.action, pwd);
        if (page.stackView.depth > 1)
            page.stackView.pop(page.stackView.get(0)); // pop to main
        ShellUI.closePopup(page.screenName);
    }

    Component.onCompleted: passwordInput.forceActiveFocus()
    Component.onDestruction: passwordInput.text = ""

    Column {
        id: column
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingNormal

        Text {
            width: column.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: page.title
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        Rectangle {
            width: column.width
            implicitHeight: passwordInput.implicitHeight + Theme.paddingSmall * 2
            radius: Theme.radiusSmall
            color: Theme.backgroundColor
            border.width: 1
            border.color: Qt.alpha(Theme.foregroundColor, 0.15)

            TextInput {
                id: passwordInput
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }
                echoMode: TextInput.Password
                color: Theme.foregroundColor
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamily
                clip: true
                Keys.onReturnPressed: page.submit()
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingSmall

            Rectangle {
                width: 80
                height: confirmLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: confirmArea.containsMouse ? Theme.accentColor : Qt.alpha(Theme.accentColor, 0.3)
                Text {
                    id: confirmLabel
                    anchors.centerIn: parent
                    text: page.mode === "connect" ? "Connect" : "Confirm"
                    color: confirmArea.containsMouse ? Theme.surfaceColor : Theme.accentColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: confirmArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: page.submit()
                }
            }

            Rectangle {
                width: 80
                height: cancelLabel.implicitHeight + Theme.paddingSmall * 2
                radius: Theme.radiusSmall
                color: cancelArea.containsMouse ? Qt.alpha(Theme.mutedColor, 0.3) : "transparent"
                Text {
                    id: cancelLabel
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: Theme.mutedColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: cancelArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        passwordInput.text = "";
                        page.stackView.pop();
                    }
                }
            }
        }
    }
}

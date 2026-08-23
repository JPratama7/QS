pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell.Networking
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../shared"
import "."

Item {
    id: page

    required property var network
    required property string screenName
    required property StackView stackView

    // Re-resolve by name on every model churn — the backend recreates WifiNetwork
    // objects on each scan, so the caller-held reference may be stale (plan §5.3).
    readonly property var current: {
        if (!page.network)
            return null
        const nets = Network.networks
        const count = nets ? nets.count : 0  // dependency: re-resolves on model churn
        if (!nets)
            return null
        return Network._resolveNetworkByName(page.network.name)
    }

    // Password mode: shown directly for unknown WpaPsk/Wpa2Psk/Sae, or flipped on
    // a NoSecrets failure for Unknown/EAP networks.
    property bool passwordMode: false
    property string errorText: ""
    property bool showPassword: false
    property bool _confirmDialog: false

    readonly property int maxMenuHeight: ShellConfig.trayMenuMaxHeight
    readonly property int headerHeight: backButton.height + Theme.spacingSmall
    readonly property int contentHeight: headerHeight + pageColumn.implicitHeight + Theme.paddingNormal * 2

    implicitWidth: width
    implicitHeight: Math.min(contentHeight, headerHeight + maxMenuHeight)

    Component.onCompleted: {
        const net = page.current
        if (net && !net.connected && !net.known) {
            const sec = net.security
            if (sec === WifiSecurityType.WpaPsk
                || sec === WifiSecurityType.Wpa2Psk
                || sec === WifiSecurityType.Sae)
                page.passwordMode = true
        }
        if (page.passwordMode)
            passwordInput.forceActiveFocus()
    }

    // Inline error fed by Network.connectFailed; flip to password mode on NoSecrets.
    // The service substitutes the network name into reasonText, so NoSecrets is
    // detected by its distinctive prefix ("Credentials required").
    Connections {
        target: Network
        function onConnectFailed(networkName, reasonText) {
            if (!page.network || networkName !== page.network.name)
                return
            page.errorText = reasonText
            if (reasonText.indexOf("Credentials required") === 0)
                page.passwordMode = true
        }
    }

    function clearError(): void { page.errorText = "" }
    function closeDialog(): void { page._confirmDialog = false }

    // Passwords are never persisted or logged — cleared immediately after use.
    function submitPassword(): void {
        const pw = passwordInput.text.trim()
        passwordInput.text = ""
        if (pw === "")
            return
        page.clearError()
        Network.connectWithPassword(page.current, pw)
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

            // SSID header + signal icon
            Item {
                width: pageColumn.width
                height: ssidLabel.implicitHeight + Theme.paddingSmall * 2
                Row {
                    spacing: Theme.spacingSmall
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: Theme.paddingSmall
                    SvgIcon {
                        source: {
                            const net = page.current
                            if (!net)
                                return "icons/outline/wifi.svg"
                            const level = Math.max(0, Math.min(3, Math.floor(net.signalStrength * 4)))
                            return level === 3 ? "icons/outline/wifi.svg" : "icons/outline/wifi-" + level + ".svg"
                        }
                        color: Theme.foregroundColor
                        iconSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: ssidLabel
                        text: page.current ? page.current.name : (page.network ? page.network.name : "")
                        color: Theme.foregroundColor
                        font.pixelSize: Theme.fontSizeNormal
                        font.family: Theme.fontFamily
                        font.bold: true
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Disconnect (when connected)
            NetworkMenuRow {
                iconSource: "icons/outline/wifi-off.svg"
                label: "Disconnect"
                destructive: true
                visible: page.current && page.current.connected
                enabled: !Network.busy
                onClicked: {
                    page.clearError()
                    Network.disconnectNetwork(page.current)
                }
            }

            // Connect (when not connected and not in password mode)
            NetworkMenuRow {
                iconSource: "icons/outline/wifi.svg"
                label: "Connect"
                visible: page.current && !page.current.connected && !page.passwordMode
                enabled: !Network.busy
                onClicked: {
                    page.clearError()
                    Network.connectNetwork(page.current)
                }
            }

            // Password input (password mode)
            Item {
                width: pageColumn.width
                height: visible ? passwordColumn.implicitHeight : 0
                visible: page.passwordMode && page.current && !page.current.connected
                Column {
                    id: passwordColumn

                    spacing: Theme.spacingSmall

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Theme.paddingSmall
                    }
                    Row {
                        width: parent.width
                        spacing: Theme.spacingSmall
                        Rectangle {
                            width: parent.width - eyeToggle.width - Theme.spacingSmall
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
                                echoMode: page.showPassword ? TextInput.Normal : TextInput.Password
                                color: Theme.foregroundColor
                                font.pixelSize: Theme.fontSizeNormal
                                font.family: Theme.fontFamily
                                clip: true
                                Keys.onReturnPressed: page.submitPassword()
                            }
                        }
                        Rectangle {
                            id: eyeToggle

                            width: Theme.iconSizeSmall + Theme.paddingSmall * 2
                            height: passwordInput.implicitHeight + Theme.paddingSmall * 2
                            radius: Theme.radiusSmall
                            color: eyeArea.containsMouse ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"
                            SvgIcon {
                                source: page.showPassword ? "icons/outline/eye-off.svg" : "icons/outline/eye.svg"
                                color: Theme.mutedColor
                                iconSize: Theme.fontSizeSmall
                                anchors.centerIn: parent
                            }
                            MouseArea {
                                id: eyeArea

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: page.showPassword = !page.showPassword
                            }
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.spacingSmall
                        Rectangle {
                            width: 80
                            height: connectBtnLabel.implicitHeight + Theme.paddingSmall * 2
                            radius: Theme.radiusSmall
                            color: connectBtnArea.containsMouse ? Theme.accentColor : Qt.alpha(Theme.accentColor, 0.3)
                            Text {
                                id: connectBtnLabel
                                anchors.centerIn: parent
                                text: "Connect"
                                color: connectBtnArea.containsMouse ? Theme.surfaceColor : Theme.accentColor
                                font.pixelSize: Theme.fontSizeSmall
                                font.family: Theme.fontFamily
                            }
                            MouseArea {
                                id: connectBtnArea

                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: page.submitPassword()
                            }
                        }
                    }
                }
            }

            // Forget (known networks only)
            NetworkMenuRow {
                iconSource: "icons/outline/wifi-off.svg"
                label: "Forget"
                destructive: true
                visible: page.current && page.current.known
                onClicked: page._confirmDialog = true
            }

            // Inline error line
            Text {
                width: pageColumn.width
                text: page.errorText
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                wrapMode: Text.WordWrap
                visible: page.errorText !== ""
                topPadding: Theme.paddingSmall
                bottomPadding: Theme.paddingSmall
                leftPadding: Theme.paddingSmall
            }
        }
    }

    ConfirmActionDialog {
        anchors.fill: parent
        visible: page._confirmDialog
        action: "Forget " + (page.current ? page.current.name : "")
        onConfirmed: {
            if (page.current)
                Network.forgetNetwork(page.current)
            page.closeDialog()
        }
        onCancelled: page.closeDialog()
    }
}

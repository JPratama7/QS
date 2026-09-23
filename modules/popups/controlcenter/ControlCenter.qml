pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
// Aliased: an unaliased import exports the C++ type `Network`, which shadows
// the services/system `Network` singleton and silently breaks its methods.
// Only the enums are needed here.
import Quickshell.Networking as NetApi
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../network"
import "../session"

// Control center card — one quick-settings surface replacing the separate
// network/volume/battery/notification popups (DESIGN_GUIDE.md §2).
// Composition top→bottom: volume slider, brightness slider, 2×2 toggle grid,
// inline Wi-Fi list, footer actions.
Item {
    id: root

    required property string screenName

    readonly property int popupWidth: 360
    readonly property int maxPopupHeight: 480

    // Network to jump to from an inline wifi row (opened via NetworkMenu)
    property var startNetwork: null

    implicitWidth: popupWidth
    implicitHeight: Math.min(column.implicitHeight + Theme.paddingNormal * 2, maxPopupHeight)
    clip: true

    // Wi-Fi list lives inline — scan while the card is open, stop on close.
    Component.onCompleted: {
        if (Network.nmAvailable)
            Network.startScan();
    }
    Component.onDestruction: Network.stopScan()

    function openNetworkMenu(network: var): void {
        const screen = ScreenRegistry.screenByName(root.screenName);
        const menuWidth = 260;
        const anchorX = screen ? Math.max(0, Math.round(screen.width / 2 - menuWidth / 2)) : 0;
        root.startNetwork = network;
        ShellUI.openPopup(root.screenName, "network", networkMenuComponent, anchorX);
    }
    function openSessionMenu(): void {
        const screen = ScreenRegistry.screenByName(root.screenName);
        const menuWidth = 340;
        const anchorX = screen ? Math.max(0, Math.round(screen.width / 2 - menuWidth / 2)) : 0;
        ShellUI.openPopup(root.screenName, "session", sessionMenuComponent, anchorX);
    }

    // Subtle glow layer behind the card — accent halo, no shadows in QS
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 6
        height: parent.height - 6
        radius: Theme.radiusGlassy
        color: Qt.alpha(Theme.accentColor, 0.05)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.glassSurface
        radius: Theme.radiusGlassy
        border.width: 1
        border.color: Theme.glassBorder
    }

    Column {
        id: column

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingNormal

        // Header
        Text {
            text: "Control Center"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
            font.family: Theme.fontFamily
            font.weight: Font.Medium
        }

        // Volume slider — icon click toggles mute
        ControlSlider {
            width: parent.width
            iconSource: "icons/outline/volume.svg"
            iconColor: Audio.muted ? Theme.errorColor : Theme.accentColor
            iconClickable: true
            value: Audio.volume
            valueText: Math.round(Audio.volume * 100) + "%"

            onIconClicked: Audio.toggleMute()
            onChanged: v => Audio.setVolume(v)
        }

        // Brightness slider — hidden when no backlight device (brightnessctl)
        ControlSlider {
            visible: Brightness.available
            width: parent.width
            iconSource: "icons/outline/sun.svg"
            value: Brightness.percent
            valueText: Math.round(Brightness.percent * 100) + "%"

            onChanged: v => Brightness.setPercent(v)
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        // Toggle grid 2×2 — Wi-Fi + DnD live; BT/night-light stubs behind flags
        Grid {
            id: toggleGrid

            columns: 2
            spacing: Theme.spacingNormal
            width: parent.width

            ControlToggle {
                width: (toggleGrid.width - toggleGrid.spacing) / 2
                iconSource: "icons/outline/wifi.svg"
                label: "Wi-Fi"
                // Strict bool — wifiEnabled can be undefined without a backend
                checked: Network.wifiEnabled === true

                onToggled: Network.toggleWifi()
            }
            ControlToggle {
                width: (toggleGrid.width - toggleGrid.spacing) / 2
                visible: Defaults.controlCenter.showBluetoothStub
                iconSource: "icons/outline/bluetooth.svg"
                label: "Bluetooth"
                checked: false
            }
            ControlToggle {
                width: (toggleGrid.width - toggleGrid.spacing) / 2
                iconSource: "icons/outline/bell.svg"
                label: "Do Not Disturb"
                checked: Notification.dndEnabled

                onToggled: Notification.toggleDnd()
            }
            ControlToggle {
                width: (toggleGrid.width - toggleGrid.spacing) / 2
                visible: Defaults.controlCenter.showNightLightStub
                iconSource: "icons/outline/moon.svg"
                label: "Night Light"
                checked: false
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        // Wi-Fi list inline — same rows as the network menu, no submenu host
        Text {
            text: "Wi-Fi"
            color: Theme.mutedColor
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
        }

        ScrollView {
            id: wifiScroll

            width: parent.width
            // Cap implicit height so a long network list doesn't inflate the
            // card to its max — the card hugs its content (DESIGN_GUIDE §2)
            implicitHeight: Math.min(wifiList.implicitHeight, 140)
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                id: wifiList

                width: wifiScroll.width
                spacing: 2

                Repeater {
                    model: Network.networks

                    delegate: NetworkMenuRow {
                        required property var modelData

                        width: parent.width
                        iconSource: {
                            const level = Math.max(0, Math.min(3, Math.floor(modelData.signalStrength * 4)));
                            return level === 3 ? "icons/outline/wifi.svg" : "icons/outline/wifi-" + level + ".svg";
                        }
                        label: modelData.name
                        trailingIcon: modelData.connected
                            ? "icons/outline/check.svg"
                            : (modelData.security !== NetApi.WifiSecurityType.Open ? "icons/outline/lock.svg" : "")
                        trailingColor: modelData.connected ? Theme.accentColor : Theme.mutedColor

                        onClicked: root.openNetworkMenu(modelData)
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.glassBorder
        }

        // Footer actions
        Row {
            width: parent.width
            spacing: Theme.spacingNormal

            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: footerLabel.implicitHeight + Theme.paddingNormal * 2
                radius: Theme.radiusInner
                color: networkArea.containsMouse ? Theme.accentSoft : Qt.alpha(Theme.foregroundColor, 0.05)

                Text {
                    id: footerLabel

                    anchors.centerIn: parent
                    text: "Network settings\u2026"
                    color: Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: networkArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.openNetworkMenu(null)
                }
            }
            Rectangle {
                width: (parent.width - parent.spacing) / 2
                height: sessionLabel.implicitHeight + Theme.paddingNormal * 2
                radius: Theme.radiusInner
                color: sessionArea.containsMouse ? Theme.accentSoft : Qt.alpha(Theme.foregroundColor, 0.05)

                Text {
                    id: sessionLabel

                    anchors.centerIn: parent
                    text: "Session\u2026"
                    color: Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    id: sessionArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.openSessionMenu()
                }
            }
        }
    }

    Component {
        id: networkMenuComponent

        NetworkMenu {
            screenName: root.screenName
            startNetwork: root.startNetwork
        }
    }
    Component {
        id: sessionMenuComponent

        SessionMenu {
            screenName: root.screenName
        }
    }
}

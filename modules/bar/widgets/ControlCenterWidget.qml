pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "../../../components/bar"
import "../../../components"
import "../../../config"
import "../../../services/system"
import "../../../services/ui"
import "../../popups/controlcenter"
import "../../popups/notifications"
import "../../popups/tray"

// Single control-center anchor for the right cluster (DESIGN_GUIDE.md §1):
// network, volume, battery collapse into this group and open the control
// center; the bell keeps its notification popup and tray icons keep their
// menus. Each sub-icon keeps its own tooltip.
BaseWidget {
    id: widget

    required property string screenName
    required property PanelWindow barWindow

    implicitWidth: groupRow.implicitWidth + Theme.paddingSmall * 2
    implicitHeight: groupRow.implicitHeight + Theme.paddingSmall

    function showSubTooltip(target: Item, tooltip: Component): void {
        if (target && tooltip)
            Tooltip.show(target, tooltip, widget.screenName, widget.barWindow);
        else
            Tooltip.hide();
    }

    function openControlCenter(): void {
        const pos = widget.mapToItem(null, 0, 0);
        const ccWidth = 360;
        const anchorX = Math.max(0, Math.min(pos.x, widget.barWindow.width - ccWidth - Theme.paddingNormal));
        ShellUI.openPopup(widget.screenName, "controlcenter", controlCenterComponent, anchorX);
    }

    // Group hover pill — HoverHandler is passive, sub-icon clicks still land
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusInner
        color: groupHover.hovered ? Theme.hoverColor : "transparent"
    }

    Row {
        id: groupRow

        anchors.centerIn: parent
        spacing: 2

        // --- Network → control center ---
        SubIcon {
            id: networkIcon

            iconSource: Network.connected ? "icons/outline/wifi.svg" : "icons/outline/wifi-off.svg"
            iconColor: Network.connected ? Theme.foregroundColor : Theme.mutedColor
            tooltipComponent: Component {
                Text {
                    text: Network.connected ? "WiFi: " + Network.ssid : "WiFi: Off"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.foregroundColor
                }
            }
            onHoverChanged: hovered => widget.showSubTooltip(networkIcon, hovered ? networkIcon.tooltipComponent : null)
            onClicked: widget.openControlCenter()
        }

        // --- Volume → control center ---
        SubIcon {
            id: volumeIcon

            iconSource: "icons/outline/volume.svg"
            iconColor: Audio.muted ? Theme.errorColor : Theme.foregroundColor
            tooltipComponent: Component {
                Column {
                    spacing: Theme.spacingSmall
                    Text {
                        visible: Audio.sinkDescription !== ""
                        text: Audio.sinkDescription
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.foregroundColor
                    }
                    Text {
                        text: Audio.muted ? "Muted" : "Volume: " + Math.round(Audio.volume * 100) + "%"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Audio.muted ? Theme.mutedColor : Theme.foregroundColor
                    }
                }
            }
            onHoverChanged: hovered => widget.showSubTooltip(volumeIcon, hovered ? volumeIcon.tooltipComponent : null)
            onClicked: widget.openControlCenter()
        }

        // --- Battery → control center ---
        SubIcon {
            id: batteryIcon

            visible: Power.present
            iconSource: {
                if (Power.charging)
                    return "icons/battery-charge-minimalistic-svgrepo-com.svg";
                if (Power.percent < 20)
                    return "icons/battery-low-minimalistic-svgrepo-com.svg";
                if (Power.percent < 60)
                    return "icons/battery-half-minimalistic-svgrepo-com.svg";
                return "icons/battery-full-minimalistic-svgrepo-com.svg";
            }
            iconColor: {
                if (Power.charging)
                    return Theme.accentColor;
                if (Power.percent < 20)
                    return Theme.errorColor;
                return Theme.foregroundColor;
            }
            tooltipComponent: Component {
                Text {
                    text: !Power.present ? "On AC Power" : (Power.charging ? "Charging: " + Power.percent + "%" : "Battery: " + Power.percent + "%")
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.foregroundColor
                }
            }
            onHoverChanged: hovered => widget.showSubTooltip(batteryIcon, hovered ? batteryIcon.tooltipComponent : null)
            onClicked: widget.openControlCenter()
        }

        // --- Bell → notification popup (keeps its own) ---
        SubIcon {
            id: bellIcon

            iconSource: Notification.dndEnabled ? "icons/outline/bell-off.svg" : (Notification.unreadCount > 0 ? "icons/outline/bell-ringing.svg" : "icons/outline/bell.svg")
            iconColor: Notification.dndEnabled ? Theme.accentColor : (Notification.unreadCount > 0 ? Theme.foregroundColor : Theme.mutedColor)
            tooltipComponent: Component {
                Text {
                    text: Notification.dndEnabled ? "Do Not Disturb is on — " + Notification.unreadCount + " pending" : (Notification.unreadCount > 0 ? "Notifications: " + Notification.unreadCount : "No notifications")
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.foregroundColor
                }
            }
            badgeCount: Notification.unreadCount
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onHoverChanged: hovered => widget.showSubTooltip(bellIcon, hovered ? bellIcon.tooltipComponent : null)
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    Notification.toggleDnd();
                    return;
                }
                const pos = bellIcon.mapToItem(null, 0, 0);
                ShellUI.openPopup(widget.screenName, "notifications", notificationPopupComponent, pos.x);
            }
        }

        // --- Tray icons → tray menu ---
        Repeater {
            model: Tray.items

            delegate: SubIcon {
                id: trayItem
                required property SystemTrayItem modelData

                // modelData flips to null when the host deletes the item: the
                // row is removed synchronously but the delegate object lingers
                // until the next event-loop pass, and QML re-evaluates its
                // bindings on the QObject destroy notification. Guard reads.
                iconImageSource: trayItem.modelData ? trayItem.modelData.icon : ""
                iconColor: Theme.foregroundColor
                tooltipComponent: Component {
                    Text {
                        text: trayItem.modelData ? (trayItem.modelData.title || "System Tray") : ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.foregroundColor
                    }
                }
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onHoverChanged: hovered => widget.showSubTooltip(trayItem, hovered ? trayItem.tooltipComponent : null)
                onClicked: mouse => {
                    const item = trayItem.modelData;
                    if (!item)
                        return;
                    if (mouse.button === Qt.RightButton || item.onlyMenu || item.hasMenu) {
                        if (item.hasMenu) {
                            const pos = trayItem.mapToItem(null, 0, 0);
                            Tray.setActiveRequest(item, pos.x);
                            ShellUI.openPopup(widget.screenName, "tray", trayMenuComponent, pos.x);
                        }
                    } else {
                        item.activate();
                    }
                }
            }
        }

        // --- Chevron → control center ---
        SubIcon {
            id: chevronIcon

            iconSource: "icons/outline/chevron-down.svg"
            iconColor: Theme.accentColor
            tooltipComponent: Component {
                Text {
                    text: "Control Center"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.foregroundColor
                }
            }
            onHoverChanged: hovered => widget.showSubTooltip(chevronIcon, hovered ? chevronIcon.tooltipComponent : null)
            onClicked: widget.openControlCenter()
        }
    }

    // Whole-group hover for the pill; passive so sub-icon clicks pass through.
    HoverHandler {
        id: groupHover

        target: widget
    }

    Component {
        id: controlCenterComponent

        ControlCenter {
            screenName: widget.screenName
        }
    }
    Component {
        id: notificationPopupComponent

        NotificationPopup {
            screenName: widget.screenName
        }
    }
    Component {
        id: trayMenuComponent

        TrayMenu {
            screenName: widget.screenName
            menuHandle: Tray.activeRequest ? Tray.activeRequest.item.menu : null
        }
    }
}

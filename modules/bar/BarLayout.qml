pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"
import "widgets"

Item {
    id: barLayout

    required property string screenName
    required property PanelWindow barWindow

    anchors.fill: parent
    anchors.leftMargin: Theme.paddingNormal
    anchors.rightMargin: Theme.paddingNormal

    property string activeTooltipWidgetId: ""
    property string pendingTooltipWidgetId: ""
    property string tooltipText: ""
    property int tooltipAnchorX: 0
    property bool tooltipVisible: false

    function defaultTooltipText(widgetId: string): string {
        switch (widgetId) {
        case "launcher":
            return "Launcher";
        case "workspaces":
            return "Workspaces";
        case "activeWindow":
            return "Active Window";
        case "clock":
            return "Clock";
        case "network":
            return "Network";
        case "volume":
            return "Volume";
        case "battery":
            return "Battery";
        case "notifications":
            return "Notifications";
        case "tray":
            return "Tray";
        case "session":
            return "Session";
        }
        return "";
    }

    function tooltipDelayMs(): int {
        const barConfig = ShellConfig.bar || {}
        const tooltipConfig = barConfig.tooltip || {}
        const configuredDelay = tooltipConfig.delayMs

        if (typeof configuredDelay === "number" && configuredDelay >= 0)
            return configuredDelay

        return Defaults.bar.tooltip.delayMs
    }

    function tooltipSettingsForWidget(widgetId: string): var {
        const barConfig = ShellConfig.bar || {}
        const tooltipConfig = barConfig.tooltip || {}
        const widgetsConfig = ShellConfig.barWidgetsConfig()
        const widgetConfig = widgetsConfig[widgetId] || {}
        const widgetTooltipConfig = widgetConfig.tooltip || {}

        const globalEnabled = typeof tooltipConfig.enabled === "boolean"
            ? tooltipConfig.enabled
            : Defaults.bar.tooltip.enabled
        const widgetEnabled = typeof widgetTooltipConfig.enabled === "boolean"
            ? widgetTooltipConfig.enabled
            : true

        const defaultText = defaultTooltipText(widgetId)
        const configuredText = widgetTooltipConfig.text
        const text = (typeof configuredText === "string" && configuredText !== "")
            ? configuredText
            : defaultText

        return {
            "enabled": globalEnabled && widgetEnabled,
            "text": text
        }
    }

    function showTooltip(widgetId: string, anchorItem: Item): void {
        const tooltipSettings = tooltipSettingsForWidget(widgetId)
        if (!tooltipSettings.enabled || tooltipSettings.text === "") {
            hideTooltip(widgetId)
            return
        }

        const position = anchorItem.mapToItem(barLayout, anchorItem.width / 2, anchorItem.height)
        activeTooltipWidgetId = widgetId
        tooltipText = tooltipSettings.text
        tooltipAnchorX = position.x
        tooltipVisible = true
    }

    function requestTooltip(widgetId: string, anchorItem: Item): void {
        const tooltipSettings = tooltipSettingsForWidget(widgetId)
        if (!tooltipSettings.enabled || tooltipSettings.text === "")
            return

        const position = anchorItem.mapToItem(barLayout, anchorItem.width / 2, anchorItem.height)
        pendingTooltipWidgetId = widgetId
        tooltipText = tooltipSettings.text
        tooltipAnchorX = position.x

        const delay = tooltipDelayMs()
        if (delay <= 0) {
            showTooltip(widgetId, anchorItem)
            return
        }

        tooltipTimer.interval = delay
        tooltipTimer.restart()
    }

    function hideTooltip(widgetId: string): void {
        if (pendingTooltipWidgetId === widgetId) {
            pendingTooltipWidgetId = ""
            tooltipTimer.stop()
        }
        if (activeTooltipWidgetId === widgetId) {
            activeTooltipWidgetId = ""
            tooltipVisible = false
        }
    }

    Timer {
        id: tooltipTimer
        repeat: false
        onTriggered: {
            if (barLayout.pendingTooltipWidgetId === "")
                return
            const widgetId = barLayout.pendingTooltipWidgetId
            barLayout.pendingTooltipWidgetId = ""
            barLayout.activeTooltipWidgetId = widgetId
            barLayout.tooltipVisible = true
        }
    }

    PopupWindow {
        id: tooltipWindow

        anchor.window: barLayout.barWindow
        anchor.rect.x: barLayout.tooltipAnchorX - tooltipWindow.implicitWidth / 2
        anchor.rect.y: ShellConfig.barEdge === "top"
            ? barLayout.barWindow.height + Theme.spacingSmall
            : -tooltipWindow.implicitHeight - Theme.spacingSmall

        visible: barLayout.tooltipVisible && barLayout.tooltipText !== ""
        color: "transparent"

        implicitWidth: tooltipBubble.implicitWidth
        implicitHeight: tooltipBubble.implicitHeight

        Rectangle {
            id: tooltipBubble
            radius: Theme.radiusSmall
            color: Theme.surfaceColor
            border.width: 1
            border.color: Theme.mutedColor
            implicitWidth: tooltipLabel.implicitWidth + Theme.paddingNormal * 2
            implicitHeight: tooltipLabel.implicitHeight + Theme.paddingSmall * 2

            Text {
                id: tooltipLabel
                anchors.centerIn: parent
                text: barLayout.tooltipText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.foregroundColor
            }
        }
    }

    Connections {
        target: ShellConfig
        function onBarChanged(): void {
            if (barLayout.activeTooltipWidgetId !== "")
                barLayout.tooltipVisible = false
            barLayout.activeTooltipWidgetId = ""
            barLayout.pendingTooltipWidgetId = ""
            tooltipTimer.stop()
        }
    }

    function widgetComponentForId(id: string): Component {
        switch (id) {
        case "launcher":
            return launcherComp;
        case "workspaces":
            return workspacesComp;
        case "activeWindow":
            return activeWindowComp;
        case "clock":
            return clockComp;
        case "network":
            return networkComp;
        case "volume":
            return volumeComp;
        case "battery":
            return batteryComp;
        case "notifications":
            return notificationsComp;
        case "tray":
            return trayComp;
        case "session":
            return sessionComp;
        }
        return null;
    }

    function widgetLayoutForZone(zone: string): var {
        const layout = ShellConfig.barWidgetLayoutForScreen(barLayout.screenName);
        return layout[zone] || [];
    }

    // Widget components - shared, no Loader inside
    Component {
        id: launcherComp
        LauncherButton {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: workspacesComp
        WorkspacesWidget {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: activeWindowComp
        ActiveWindowWidget {
            screenName: barLayout.screenName
        }
    }
    Component {
        id: clockComp
        ClockWidget {}
    }
    Component {
        id: networkComp
        NetworkWidget {}
    }
    Component {
        id: volumeComp
        VolumeWidget {}
    }
    Component {
        id: batteryComp
        BatteryWidget {}
    }
    Component {
        id: notificationsComp
        NotificationIndicatorWidget {}
    }
    Component {
        id: trayComp
        TrayWidget {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }
    }
    Component {
        id: sessionComp
        SessionMenuButton {
            screenName: barLayout.screenName
            barWindow: barLayout.barWindow
        }
    }

    // Left zone
    Row {
        id: leftZone

        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("left")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: leftWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: leftWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: leftHoverHandler
                    onHoveredChanged: {
                        if (hovered)
                            barLayout.requestTooltip(parent.widgetId, parent)
                        else
                            barLayout.hideTooltip(parent.widgetId)
                    }
                }
            }
        }
    }

    // Center zone
    Row {
        id: centerZone

        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("center")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: centerWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: centerWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: centerHoverHandler
                    onHoveredChanged: {
                        if (hovered)
                            barLayout.requestTooltip(parent.widgetId, parent)
                        else
                            barLayout.hideTooltip(parent.widgetId)
                    }
                }
            }
        }
    }

    // Right zone
    Row {
        id: rightZone

        height: parent.height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingSmall

        Repeater {
            model: barLayout.widgetLayoutForZone("right")
            Item {
                required property var modelData
                readonly property string widgetId: modelData
                width: rightWidgetLoader.implicitWidth
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: rightWidgetLoader
                    sourceComponent: barLayout.widgetComponentForId(parent.widgetId)
                    anchors.verticalCenter: parent.verticalCenter
                }

                HoverHandler {
                    id: rightHoverHandler
                    onHoveredChanged: {
                        if (hovered)
                            barLayout.requestTooltip(parent.widgetId, parent)
                        else
                            barLayout.hideTooltip(parent.widgetId)
                    }
                }
            }
        }
    }
}

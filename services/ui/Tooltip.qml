pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../config"

Singleton {
    id: root

    property var activeTarget: null
    property var activeComponent: null
    property var anchorWindow: null
    property string activeScreenName: ""
    property int delayMs: 500

    // Internal Binding
    readonly property string _barEdge: ShellConfig.barEdge

    function show(target: Item, tooltipComponent: Component, screenName: string, window: PanelWindow): void {
        if (!target || !tooltipComponent)
            return;

        // Hide current tooltip if showing for different target
        if (activeTarget && activeTarget !== target) {
            root.hide();
        }

        // Already showing for this target
        if (activeTarget === target) {
            showTimer.restart();
            return;
        }

        activeTarget = target;
        activeComponent = tooltipComponent;
        activeScreenName = screenName;
        anchorWindow = window;

        // Start show timer
        showTimer.restart();
    }

    function hide(): void {
        showTimer.stop();
        activeTarget = null;
        activeComponent = null;
        activeScreenName = "";
        tooltipWindow.visible = false;
        tooltipLoader.enabled = false;
        tooltipWindow.hide();
    }

    Timer {
        id: showTimer
        interval: root.delayMs
        repeat: false
        onTriggered: {
            if (root.activeTarget && root.activeComponent) {
                tooltipWindow.showTooltip();
            }
        }
    }

    PopupWindow {
        id: tooltipWindow

        property var targetItem: null
        property int margin: 8
        readonly property int marginX2: margin * 2

        visible: false
        color: "transparent"

        readonly property int paddingNormalX2: Theme.paddingNormal * 2
        readonly property int paddingSmallX2: Theme.paddingSmall * 2

        implicitWidth: tooltipLoader.implicitWidth + paddingNormalX2
        implicitHeight: tooltipLoader.implicitHeight + paddingSmallX2

        Rectangle {
            anchors.fill: parent
            radius: Theme.radiusSmall
            color: Theme.surfaceColor
            border.width: 1
            border.color: Theme.mutedColor
        }

        Loader {
            id: tooltipLoader
            anchors.fill: parent
            anchors.margins: Theme.paddingSmall
            sourceComponent: root.activeComponent

            onLoaded: {
                if (!tooltipWindow.targetItem)
                    return;

                // Defer positioning to next frame for smoother UI
                tooltipLoader.positionTooltip();
            }

            function positionTooltip(): void {
                // Check if targetItem is still valid (may have been cleared by hide)
                if (!tooltipWindow.targetItem || !root.anchorWindow) {
                    return;
                }

                // Get target position and dimensions
                const targetPos = tooltipWindow.targetItem.mapToItem(root.anchorWindow.contentItem, 0, 0);
                const tipWidth = tooltipWindow.implicitWidth;
                const tipHeight = tooltipWindow.implicitHeight;

                // Calculate combined anchor position
                const position = {
                    x: targetPos.x + tooltipWindow.targetItem.width / 2 - tipWidth / 2,
                    y: root._barEdge === "bottom" ? targetPos.y - tipHeight - tooltipWindow.margin : targetPos.y + tooltipWindow.targetItem.height + tooltipWindow.margin
                };

                // Adjust for screen edges
                const screen = ScreenRegistry.screenByName(root.activeScreenName);
                if (screen) {
                    const screenWidth = screen.width;
                    position.x = Math.max(tooltipWindow.margin, Math.min(position.x, screenWidth - tipWidth - tooltipWindow.margin));
                }

                // qmllint disable missing-property
                tooltipWindow.anchor.rect.x = position.x;
                tooltipWindow.anchor.rect.y = position.y;
                tooltipWindow.visible = true;
            }
        }

        function hide(): void {
            tooltipWindow.targetItem = null;
            tooltipWindow.anchor.rect.x = 0;
            tooltipWindow.anchor.rect.y = 0;
            tooltipWindow.anchor.window = null;
            tooltipWindow.visible = false;
            tooltipLoader.active = false;
        }
        function showTooltip(): void {
            tooltipWindow.targetItem = root.activeTarget;
            tooltipWindow.anchor.window = root.anchorWindow;
            tooltipLoader.active = true;
        }
    }

    Connections {
        target: ShellConfig
        function onBarChanged(): void {
            root.hide();
        }
    }
}

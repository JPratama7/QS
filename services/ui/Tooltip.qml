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
	property var tooltipWindow: null
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
		anchorWindow = null;

		if (root.tooltipWindow) {
			root.tooltipWindow.destroy();
			root.tooltipWindow = null;
		}
	}
	function _showTooltip(): void {
		if (!root.tooltipWindow) {
			root.tooltipWindow = tooltipWindowComponent.createObject(root);
		}
		root.tooltipWindow.showTooltip();
	}

	Timer {
		id: showTimer

		interval: root.delayMs
		repeat: false

		onTriggered: {
			if (root.activeTarget && root.activeComponent) {
				root._showTooltip();
			}
		}
	}
	Component {
		id: tooltipWindowComponent

		PopupWindow {
			id: tooltipWindow

			property var targetItem: null
			property int margin: 8
			readonly property int marginX2: margin * 2
			readonly property int paddingNormalX2: Theme.paddingNormal * 2
			readonly property int paddingSmallX2: Theme.paddingSmall * 2

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

			visible: false
			color: "transparent"
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

				function positionTooltip(): void {
					if (!tooltipWindow.targetItem || !root.anchorWindow) {
						return;
					}

					const targetPos = tooltipWindow.targetItem.mapToItem(root.anchorWindow.contentItem, 0, 0);
					const tipWidth = tooltipWindow.implicitWidth;
					const tipHeight = tooltipWindow.implicitHeight;

					const position = {
						x: targetPos.x + tooltipWindow.targetItem.width / 2 - tipWidth / 2,
						y: root._barEdge === "bottom" ? targetPos.y - tipHeight - tooltipWindow.margin : targetPos.y + tooltipWindow.targetItem.height + tooltipWindow.margin
					};

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

				anchors.fill: parent
				anchors.margins: Theme.paddingSmall
				active: false
				sourceComponent: root.activeComponent

				onLoaded: {
					if (!tooltipWindow.targetItem)
						return;

					tooltipLoader.positionTooltip();
				}
			}
		}
	}
	Connections {
		function onBarChanged(): void {
			root.hide();
		}

		target: ShellConfig
	}
}

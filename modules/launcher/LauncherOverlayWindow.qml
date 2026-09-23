pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services/launcher"
import "../../services/system"
import "../search"

PanelWindow {
	id: overlay

	required property string screenName

	function reset(): void {
		launcherView.reset();
	}

	anchors {
		top: true
		left: true
		right: true
		bottom: true
	}

	color: Qt.alpha(Theme.backgroundColor, ShellConfig.overlayOpacity)

	visible: false

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.keyboardFocus: overlay.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-launcher-" + overlay.screenName
	WlrLayershell.exclusionMode: ExclusionMode.Ignore

	// Scrim: close on click outside the launcher view, consume clicks inside
	// so padding around the search field doesn't dismiss the launcher.
	MouseArea {
		anchors.fill: parent
		onClicked: (mouse) => {
			const viewRect = mapFromItem(launcherView, 0, 0);
			const outside = (mouse.x < viewRect.x || mouse.x > viewRect.x + launcherView.width ||
					mouse.y < viewRect.y || mouse.y > viewRect.y + launcherView.height);
			if (outside)
				Launcher.close();
			mouse.accepted = true;
		}
	}

	// Two-pane launcher card — list left, preview right (DESIGN_GUIDE.md §3)
	Item {
		id: launcherView

		anchors.centerIn: parent
		width: Defaults.launcherWidth
		height: Math.min(implicitHeight, parent.height - Defaults.launcherVerticalMargin)
		focus: true

		// Keyboard handling lives on the card so the field keeps focus
		Keys.onUpPressed: Launcher.selectPrev()
		Keys.onDownPressed: Launcher.selectNext()
		Keys.onReturnPressed: Launcher.activateSelected()
		Keys.onEscapePressed: Launcher.close()

		function reset(): void {
			searchField.clear();
			searchField.focusInput();
		}

		// Height = taller of the two panes. Left pane sums actual heights (the
		// results list is height-capped, so its implicit height lies); right
		// pane needs room for the preview column, else it spills past the
		// glass chrome onto the desktop.
		implicitHeight: Math.max(
			searchField.height + resultsList.height + leftColumn.spacing,
			previewColumn.implicitHeight
		) + Theme.paddingNormal * 2

		// Glow layer behind the card
		Rectangle {
			anchors.centerIn: parent
			width: parent.width - 8
			height: parent.height - 8
			radius: Theme.radiusGlassy
			color: Qt.alpha(Theme.accentColor, 0.05)
		}
		// Card chrome — glass surface, glassy radius, hairline border
		Rectangle {
			anchors.fill: parent
			color: Theme.glassSurface
			radius: Theme.radiusGlassy
			border.width: 1
			border.color: Theme.glassBorder
		}

		Row {
			id: cardRow

			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
				bottom: parent.bottom
				margins: Theme.paddingNormal
			}
			spacing: Theme.spacingNormal

			// Left pane — search field + results list
			Column {
				id: leftColumn

				width: parent.width * 0.46
				spacing: Theme.spacingNormal

				SearchField {
					id: searchField

					width: parent.width
					searchService: Launcher
					placeholderText: "Search applications..."
				}

				SearchResultsList {
					id: resultsList

					width: parent.width
					height: Math.min(implicitHeight, Defaults.launcherResultsHeight)
					searchService: Launcher
					resultDelegate: launcherResultDelegate
					emptyQueryHint: "Start typing to search"
					emptyNoResultsHint: "No results"
					reserveEmptySpace: true
				}
			}

			// Divider between panes
			Rectangle {
				id: divider

				width: 1
				height: parent.height
				color: Theme.glassBorder
			}

			// Right pane — preview of the selected result
			Item {
				id: rightPane

				width: parent.width - leftColumn.width - divider.width - parent.spacing * 2
				height: parent.height
				clip: true

				// Preview content, centered
				Column {
					id: previewColumn

					anchors.centerIn: parent
					width: parent.width
					spacing: Theme.spacingNormal
					visible: Launcher.selectedResult !== null

					// Big icon chip
					Rectangle {
						anchors.horizontalCenter: parent.horizontalCenter
						width: 64
						height: 64
						radius: 18
						color: Theme.accentSoft
						border.width: 1
						border.color: Theme.accentBorder

						Image {
							anchors.centerIn: parent
							width: 30
							height: 30
							fillMode: Image.PreserveAspectFit
							sourceSize.width: 30
							sourceSize.height: 30
							source: Launcher.selectedResult ? AppIcons.iconFromName(Launcher.selectedResult.icon) : ""
						}
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						text: Launcher.selectedResult ? Launcher.selectedResult.title : ""
						color: Theme.foregroundColor
						font.pixelSize: Theme.fontSizeLarge
						font.family: Theme.fontFamily
						font.weight: Font.Medium
						horizontalAlignment: Text.AlignHCenter
						elide: Text.ElideRight
						width: parent.width
					}

					Text {
						anchors.horizontalCenter: parent.horizontalCenter
						text: Launcher.selectedResult ? (Launcher.selectedResult.subtitle || "No description") : ""
						color: Theme.mutedColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
						horizontalAlignment: Text.AlignHCenter
						wrapMode: Text.WordWrap
						width: parent.width - Theme.paddingNormal * 2
					}

					// Hint line
					Row {
						anchors.horizontalCenter: parent.horizontalCenter
						spacing: Theme.spacingLarge
						topPadding: Theme.paddingSmall

						Text {
							text: "\u21B5 launch"
							color: Qt.alpha(Theme.mutedColor, 0.7)
							font.pixelSize: Theme.fontSizeSmall - 2
							font.family: Theme.fontFamilyMono
						}
						Text {
							text: "esc close"
							color: Qt.alpha(Theme.mutedColor, 0.7)
							font.pixelSize: Theme.fontSizeSmall - 2
							font.family: Theme.fontFamilyMono
						}
					}
				}

				// Empty state — no selection
				Text {
					anchors.centerIn: parent
					text: "No selection"
					color: Theme.mutedColor
					font.pixelSize: Theme.fontSizeSmall
					font.family: Theme.fontFamily
					visible: Launcher.selectedResult === null
				}
			}
		}
	}

	Component {
		id: launcherResultDelegate

		Rectangle {
			id: resultRow

			required property var modelData
			required property int index

			readonly property bool isSelected: index === Launcher.selectedIndex

			width: parent.width
			height: rowContent.implicitHeight + Theme.paddingSmall * 2
			radius: Theme.radiusInner
			color: "transparent"

			// Selected indicator — accent bar at the leading edge (mockup)
			Rectangle {
				visible: resultRow.isSelected
				width: 3
				height: parent.height - Theme.paddingSmall * 2
				radius: 2
				color: Theme.accentColor
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 2
			}

			Row {
				id: rowContent

				spacing: Theme.spacingSmall

				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Theme.paddingNormal
				}
				Image {
					width: Theme.iconSizeSmall
					height: Theme.iconSizeSmall
					fillMode: Image.PreserveAspectFit
					sourceSize.width: Theme.iconSizeSmall
					sourceSize.height: Theme.iconSizeSmall
					source: AppIcons.iconFromName(resultRow.modelData.icon)
				}
				Column {
					anchors.verticalCenter: parent.verticalCenter
					spacing: 2

					Text {
						text: resultRow.modelData.title
						color: Theme.foregroundColor
						font.pixelSize: Theme.fontSizeSmall
						font.family: Theme.fontFamily
					}
					Text {
						text: resultRow.modelData.subtitle
						color: Theme.mutedColor
						font.pixelSize: Theme.fontSizeSmall - 1
						font.family: Theme.fontFamily
						visible: text !== ""
					}
				}
			}
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true

				onEntered: Launcher.selectedIndex = resultRow.index
				onClicked: Launcher.activateSelected()
			}
		}
	}
}

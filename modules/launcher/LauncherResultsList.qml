pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import "../../config"
import "../../services/launcher"
import "../../services/system"

Item {
	id: list

	implicitHeight: resultsView.contentHeight
	visible: Launcher.hasResults

	ListView {
		id: resultsView

		anchors.fill: parent
		model: Launcher.results
		delegate: resultDelegate
		spacing: Theme.spacingSmall
		clip: true
		highlightFollowsCurrentItem: true
		highlightMoveDuration: Theme.listHighlightDuration
		highlightResizeDuration: Theme.listHighlightDuration
		currentIndex: Launcher.selectedIndex

		highlight: Rectangle {
			color: Qt.alpha(Theme.accentColor, 0.2)
			radius: Theme.radiusSmall
		}
	}
	Component {
		id: resultDelegate

		Rectangle {
			id: resultRow

			required property var modelData
			required property int index

			width: resultsView.width
			height: rowContent.implicitHeight + Theme.paddingSmall * 2
			radius: Theme.radiusSmall
			color: resultRow.index === Launcher.selectedIndex ? Qt.alpha(Theme.accentColor, 0.15) : "transparent"

			Row {
				id: rowContent

				spacing: Theme.spacingSmall

				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Theme.paddingSmall
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

	// Empty state
	Text {
		anchors.centerIn: parent
		text: "No results"
		color: Theme.mutedColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily
		visible: !Launcher.hasResults && Launcher.query !== ""
	}
}

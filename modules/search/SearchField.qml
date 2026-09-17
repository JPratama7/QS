pragma ComponentBehavior: Bound

import QtQuick
import "../../config"

// Shared search input for the picker overlays. Binds two-way to the picker
// service's query property; placeholder text is per-picker.
Rectangle {
	id: root

	// Picker service — must expose a `query` string property
	required property var searchService
	property string placeholderText: ""

	implicitHeight: searchInput.implicitHeight + Theme.paddingSmall * 2
	radius: Theme.radiusSmall
	color: Theme.backgroundColor
	border.width: 1
	border.color: Qt.alpha(Theme.foregroundColor, 0.15)

	function clear(): void {
		searchInput.text = "";
	}
	function focusInput(): void {
		searchInput.forceActiveFocus();
	}

	TextInput {
		id: searchInput
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			right: parent.right
			margins: Theme.paddingSmall
		}
		text: root.searchService.query
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily

		onTextChanged: {
			root.searchService.query = text;
		}
	}

	// Placeholder text
	Text {
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.paddingSmall
		}
		text: root.placeholderText
		color: Theme.mutedColor
		font.pixelSize: Theme.fontSizeNormal
		font.family: Theme.fontFamily
		visible: searchInput.text === ""
	}
}

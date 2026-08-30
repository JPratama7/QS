pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../config"

// Two-section setting row: label left, control right, hairline between.
// Anchors used instead of Layout to guarantee right-edge positioning.
Item {
	id: root

	property string text: ""
	default property alias control: controlSlot.data

	Layout.fillWidth: true
	Layout.preferredHeight: controlSlot.implicitHeight

	// Left section — what to set
	Text {
		id: label

		text: root.text
		color: Theme.foregroundColor
		font.pixelSize: Theme.fontSizeNormal
		width: 180
		elide: Text.ElideRight
		leftPadding: Theme.paddingSmall
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter

		// Full label on hover when elided
		ToolTip.visible: truncated
		ToolTip.text: root.text
	}

	// Hairline divider — the ledger rule between "what" and "value"
	Rectangle {
		id: divider

		width: 1
		height: parent.height
		anchors.left: label.right
		anchors.leftMargin: Theme.spacingNormal
		color: Theme.borderColor
	}

	// Right section — value control, anchored to right edge
	ColumnLayout {
		id: controlSlot

		anchors.right: parent.right
		anchors.rightMargin: Theme.spacingNormal
		anchors.verticalCenter: parent.verticalCenter
		spacing: 0
	}
}

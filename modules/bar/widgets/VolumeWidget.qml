pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	readonly property real _volumePercent: Math.round(Audio.volume * 100)

	implicitWidth: text.implicitWidth + Theme.paddingSmall * 2
	implicitHeight: text.implicitHeight + Theme.paddingSmall * 2

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
			Text {
				visible: Audio.channelVolumeText !== ""
				text: Audio.channelVolumeText
				font.pixelSize: Theme.fontSizeSmall
				color: Theme.foregroundColor
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		radius: Theme.radiusSmall
		color: mouseArea.containsMouse ? Theme.hoverColor : "transparent"
	}

	Text {
		id: text

		anchors.centerIn: parent
		text: Audio.muted ? "Mute" : widget._volumePercent + "%"
		color: Audio.muted ? Theme.mutedColor : Theme.foregroundColor
		font.pixelSize: Theme.fontSizeSmall
		font.family: Theme.fontFamilyMono
	}

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor

		onClicked: Audio.toggleMute()
	}
}

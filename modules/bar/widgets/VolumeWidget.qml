pragma ComponentBehavior: Bound

import QtQuick
import "../../../components/bar"
import "../../../config"
import "../../../services/system"

BaseWidget {
	id: widget

	readonly property real _volumePercent: Math.round(Audio.volume * 100)

	implicitWidth: text.implicitWidth
	implicitHeight: text.implicitHeight

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

	Text {
		id: text

		text: Audio.muted ? "Mute" : widget._volumePercent + "%"
		color: Audio.muted ? Theme.mutedColor : Theme.foregroundColor
		font.pixelSize: Theme.fontSizeSmall
		font.family: Theme.fontFamily
	}
	MouseArea {
		anchors.fill: parent

		onClicked: Audio.toggleMute()
	}
}

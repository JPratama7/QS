import QtQuick
import Quickshell
import Quickshell.Io

Item {
	id: root

	property string source: ""
	property color color: "#cdd6f4"
	property int iconSize: 16

	implicitWidth: iconSize
	implicitHeight: iconSize

	FileView {
		id: fileView

		readonly property string dataUrl: {
			var raw = text();
			if (!raw || !root.source)
				return "";
			var colored = raw.replace(/currentColor/g, root.color.toString());
			return "data:image/svg+xml;utf8," + encodeURIComponent(colored);
		}

		path: root.source !== "" ? Quickshell.shellDir + "/" + root.source : ""
	}
	Image {
		anchors.fill: parent
		source: fileView.dataUrl
		sourceSize.width: root.iconSize
		sourceSize.height: root.iconSize
		asynchronous: true
		visible: root.source !== ""
	}
}

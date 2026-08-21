pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services/system"

Rectangle {
    id: field

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
        text: Emoji.query
        color: Theme.foregroundColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily

        onTextChanged: {
            Emoji.query = text;
        }
    }

    // Placeholder text
    Text {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Theme.paddingSmall
        }
        text: "Search emoji..."
        color: Theme.mutedColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
        visible: searchInput.text === ""
    }
}

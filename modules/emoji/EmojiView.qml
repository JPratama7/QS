pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services/system"

Item {
    id: view

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight + Theme.paddingNormal * 2

    focus: true

    Keys.onUpPressed: Emoji.selectPrev()
    Keys.onDownPressed: Emoji.selectNext()
    Keys.onReturnPressed: Emoji.activateSelected()
    Keys.onEscapePressed: Emoji.close()

    function reset(): void {
        searchField.clear();
        searchField.focusInput();
    }

    Rectangle {
        z: -1
        anchors.fill: parent
        color: Theme.surfaceColor
        radius: Theme.radiusNormal
        border.width: 1
        border.color: Qt.alpha(Theme.foregroundColor, 0.1)
    }

    Column {
        id: column
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingNormal
        }
        spacing: Theme.spacingNormal

        EmojiSearchField {
            id: searchField
            width: parent.width
        }

        EmojiResultsList {
            width: parent.width
            height: Math.min(implicitHeight, 400)
        }
    }
}

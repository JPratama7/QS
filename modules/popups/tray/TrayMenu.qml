pragma ComponentBehavior: Bound

import QtQuick
import "../shared"
import "."

MenuHost {
    id: root

    required property string screenName
    required property var menuHandle
    onMenuHandleChanged: root.frozenHeight = 0

    menuWidth: 220
    initialPage: menuPage

    Component {
        id: menuPage
        TrayMenuPage {
            menuHandle: root.menuHandle
            stackView: root.stackView
            screenName: root.screenName
            width: root.menuWidth
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../types"

Item {
    id: barView

    required property ScreenContext context
    required property PanelWindow barWindow
    required property bool shown

    opacity: shown ? 1 : 0
    y: shown ? 0 : (context.barEdge === "top" ? -height : height)

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }
    Behavior on y {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    BarLayout {
        anchors.fill: parent
        screenName: barView.context.name
        barWindow: barView.barWindow
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../types"

Item {
    id: barView

    required property ScreenContext context
    required property PanelWindow barWindow

    BarLayout {
        anchors.fill: parent
        screenName: barView.context.name
        barWindow: barView.barWindow
    }
}

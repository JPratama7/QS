pragma ComponentBehavior: Bound

import QtQuick
import "../../types"

Item {
    id: barView

    required property ScreenContext context

    BarLayout {
        anchors.fill: parent
        screenName: context.name
    }
}

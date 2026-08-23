pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/ui"

QtObject {
    id: root

    property Component menuComponent: Component {
        VpnMenu {
            screenName: PopupRegistry.activeScreen
        }
    }

    Component.onCompleted: PopupRegistry.register("vpn", root.menuComponent)
}

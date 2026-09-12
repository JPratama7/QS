pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/system"
import "../../../services/ui"
import "../shared"
import "."

MenuHost {
    id: root

    required property string screenName

    menuWidth: 260
    initialPage: menuPage

    // Close the popup when a connection succeeds — but only if it's still open,
    // so a user who already dismissed it never triggers a double-close.
    Connections {
        target: Network
        function onConnectSucceeded(networkName) {
            if (ShellUI.isPopupOpen(root.screenName, "network"))
                ShellUI.closePopup(root.screenName);
        }
    }

    Component {
        id: menuPage
        NetworkMainPage {
            screenName: root.screenName
            stackView: root.stackView
            width: root.menuWidth
        }
    }
}

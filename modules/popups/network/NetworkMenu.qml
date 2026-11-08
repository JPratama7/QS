pragma ComponentBehavior: Bound

import QtQuick
import "../../../services/system"
import "../../../services/ui"
import "../shared"
import "."

MenuHost {
    id: root

    required property string screenName

    // Control center inline wifi rows jump straight to a network's action page
    // (password flow included) — the CC has no submenu host of its own.
    property var startNetwork: null

    menuWidth: 260
    initialPage: menuPage

    Component.onCompleted: {
        if (root.startNetwork) {
            Qt.callLater(() => {
                if (root.stackView.depth === 1) {
                    root.stackView.push(Qt.resolvedUrl("NetworkActionPage.qml"), {
                        network: root.startNetwork,
                        screenName: root.screenName,
                        stackView: root.stackView,
                        width: root.menuWidth
                    });
                }
            });
        }
    }

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

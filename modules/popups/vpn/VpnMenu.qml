pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Dialogs
import "../../../services/system"
import "../shared"
import "."

MenuHost {
    id: root

    required property string screenName

    menuWidth: 220
    initialPage: menuPage

    onEnter: () => { Vpn.menuOpen = true; }
    onExit: () => { Vpn.menuOpen = false; }

    // sudo -n cache miss on disconnect/disconnectAll/delete → collect password.
    // The action payload is forwarded verbatim to Vpn.supplyPassword() on submit.
    Connections {
        target: Vpn
        function onElevationRequired(action: var) {
            const verb = action.type === "delete" ? "delete" : "disconnect";
            root.stackView.push(Qt.resolvedUrl("VpnPasswordPage.qml"), {
                title: "Enter the sudo password to " + verb,
                name: action.name,
                mode: "disconnect",
                action: action,
                stackView: root.stackView,
                screenName: root.screenName,
                width: root.menuWidth
            });
        }
    }

    Component {
        id: menuPage
        VpnMainPage {
            screenName: root.screenName
            stackView: root.stackView
            width: root.menuWidth
            onImportRequested: importDialog.open()
        }
    }

    // Owned by the root so it survives page transitions (plan §5.4).
    FileDialog {
        id: importDialog
        fileMode: FileDialog.OpenFiles
        nameFilters: ["OpenVPN configuration files (*.ovpn)"]
        acceptLabel: "Import"
        onAccepted: Vpn.importConfigs(importDialog.selectedFiles)
    }
}

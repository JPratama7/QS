import QtQuick
import Quickshell
import Quickshell.Wayland

// qmllint disable uncreatable-type
PanelWindow {
    // qmllint enable uncreatable-type
    id: shellWindow

    required property string name

    WlrLayershell.namespace: `qs-rework-${name}`
    color: "transparent"
}

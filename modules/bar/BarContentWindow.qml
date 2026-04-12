import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../components/containers"
import "../../types"
import "../../config"

ShellWindow {
    id: barWindow

    required property ScreenContext context

    name: "bar-content"
    screen: context.screen

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: context.barHeight
    color: Theme.backgroundColor

    BarView {
        id: barView
        anchors.fill: parent
        context: barWindow.context
    }
}

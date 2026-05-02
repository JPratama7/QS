import "../config"
import QtQuick
import Quickshell

QtObject {
    id: context

    required property ShellScreen screen
    readonly property string name: screen.name
    readonly property bool isPrimary: ShellConfig.primaryScreen === "" || ShellConfig.primaryScreen === screen.name
    readonly property string barEdge: ShellConfig.barEdge
    readonly property int barHeight: ShellConfig.barHeight
    readonly property string barDisplayMode: ShellConfig.barDisplayMode
}

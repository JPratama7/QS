import "../config"
import QtQuick
import Quickshell

QtObject {
    id: context

    required property ShellScreen screen
    readonly property string name: screen.name
    readonly property bool isPrimary: PersistentConfig.adapter.primaryScreen === "" || PersistentConfig.adapter.primaryScreen === screen.name
    readonly property string barEdge: PersistentConfig.adapter.barEdge
    readonly property int barHeight: PersistentConfig.adapter.barHeight
    readonly property string barDisplayMode: PersistentConfig.adapter.barDisplayMode
}

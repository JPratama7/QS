pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../../config"

// Palette picker — one tile per palette in Defaults.palettes, sampled
// from the palette itself. One click re-themes the shell.
ColumnLayout {
    id: root

    property string text: ""
    property string keyPath: ""
    property string filterText: ""
    property string currentValue: ""
    readonly property bool matches: filterText === "" || text.toLowerCase().indexOf(filterText) >= 0 || keyPath.toLowerCase().indexOf(filterText) >= 0

    signal valueChanged(string newValue)

    Layout.fillWidth: true
    spacing: 0
    visible: matches

    // Same label block as SettingRow — name over key path
    Column {
        spacing: 3

        Layout.leftMargin: Theme.paddingSmall
        Layout.topMargin: 11
        Layout.bottomMargin: 10

        Text {
            text: root.text
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeNormal
        }
        Text {
            visible: root.keyPath !== ""
            text: root.keyPath
            color: Qt.alpha(Theme.mutedColor, 0.72)
            font.pixelSize: 8
            font.family: Theme.fontFamilyMono
            font.letterSpacing: 0.4
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 11
        spacing: 8

        Repeater {
            model: Object.keys(Defaults.palettes)

            delegate: Rectangle {
                id: tile

                required property string modelData
                readonly property var pal: Defaults.palettes[modelData]
                readonly property bool on: root.currentValue === modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 62
                radius: 10
                color: on ? Theme.accentSoft : Qt.alpha(Theme.backgroundColor, 0.4)
                border.width: 1
                border.color: on ? Theme.accentBorder : Theme.borderColor

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.hoverDuration
                        easing.type: Easing.OutQuad
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: Theme.hoverDuration
                        easing.type: Easing.OutQuad
                    }
                }

                Column {
                    spacing: 5

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 10
                    }
                    Row {
                        spacing: 4

                        Repeater {
                            model: [tile.pal.background, tile.pal.surface, tile.pal.accent]

                            delegate: Rectangle {
                                required property var modelData

                                width: 16
                                height: 16
                                radius: 5
                                color: modelData
                                border.width: 1
                                border.color: Theme.borderColor
                            }
                        }
                    }
                    Text {
                        text: tile.modelData
                        color: tile.on ? Theme.accentColor : Theme.foregroundColor
                        font.pixelSize: 9
                        font.family: Theme.fontFamilyMono
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: tile.pal.accent
                        color: Qt.alpha(Theme.mutedColor, 0.72)
                        font.pixelSize: 8
                        font.family: Theme.fontFamilyMono
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root.valueChanged(tile.modelData)
                }
            }
        }
    }
    // Ledger rule under the row
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.glassBorder
    }
}

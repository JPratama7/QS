pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../../../config"

// Full-width setting: label above, text field below.
// Side-by-side rows (SettingRow) overflow with long values like argv commands.
ColumnLayout {
    id: root

    property string text: ""
    property string keyPath: ""
    property string filterText: ""
    readonly property bool matches: filterText === "" || text.toLowerCase().indexOf(filterText) >= 0 || keyPath.toLowerCase().indexOf(filterText) >= 0

    // Current value as a string array (argv). Displayed space-joined.
    property var currentValue: ([])
    signal valueChanged(var newValue)

    Layout.fillWidth: true
    spacing: 6
    visible: matches

    Column {
        Layout.leftMargin: Theme.paddingSmall
        Layout.topMargin: 8
        spacing: 3

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

    TextField {
        id: field

        Layout.fillWidth: true
        Layout.preferredHeight: 32
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamilyMono
        color: Theme.foregroundColor
        selectionColor: Theme.accentColor
        placeholderText: "command args..."
        placeholderTextColor: Theme.mutedColor

        background: Rectangle {
            radius: Theme.radiusSmall
            color: Theme.backgroundColor
            border.color: field.activeFocus ? Theme.accentColor : Theme.borderColor
            border.width: 1
        }

        // Text is set imperatively (a binding would fight typing).
        Component.onCompleted: field.text = root.currentValue.join(" ")

        Connections {
            target: root

            function onCurrentValueChanged(): void {
                field.text = root.currentValue.join(" ");
            }
        }

        // Commit on enter or focus loss: split on whitespace, drop empties.
        // Invalid parse (empty result) reverts to the current value.
        onEditingFinished: {
            const parts = text.split(/\s+/).filter(p => p !== "");
            if (parts.length > 0)
                root.valueChanged(parts);
            else
                text = root.currentValue.join(" ");
        }
    }
}

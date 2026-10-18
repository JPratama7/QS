pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."
import "../../../config"

// Argv list editor: one field per token, add/remove rows.
// Emits the filtered (non-empty) token array on commit; empty rows are
// work-in-progress and never written to config.
ColumnLayout {
    id: root

    property string text: ""
    property string keyPath: ""
    property string filterText: ""
    readonly property bool matches: filterText === "" || text.toLowerCase().indexOf(filterText) >= 0 || keyPath.toLowerCase().indexOf(filterText) >= 0

    // Current value as a string array (argv).
    property var currentValue: ([])
    signal valueChanged(var newValue)

    // Internal row state; rebuilt only on external currentValue changes
    // (the _selfUpdate guard keeps self-emitted writes from rebuilding
    // fields mid-edit).
    property var _tokens: []
    property bool _selfUpdate: false

    Component.onCompleted: root._syncFromCurrent()

    onCurrentValueChanged: {
        if (!root._selfUpdate)
            root._syncFromCurrent();
    }

    function _syncFromCurrent(): void {
        const arr = [];
        for (const t of root.currentValue) {
            if (typeof t === "string")
                arr.push(t);
        }
        root._tokens = arr.length > 0 ? arr : [""];
    }

    function _commit(index: int, value: string): void {
        const copy = root._tokens.slice();
        copy[index] = value;
        root._tokens = copy;
        const filtered = copy.filter(t => t !== "");
        if (filtered.length === 0)
            return;
        root._selfUpdate = true;
        root.valueChanged(filtered);
        root._selfUpdate = false;
    }

    function _remove(index: int): void {
        const copy = root._tokens.slice();
        copy.splice(index, 1);
        root._tokens = copy.length > 0 ? copy : [""];
        const filtered = copy.filter(t => t !== "");
        if (filtered.length === 0)
            return;
        root._selfUpdate = true;
        root.valueChanged(filtered);
        root._selfUpdate = false;
    }

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

    Repeater {
        model: root._tokens.length

        delegate: RowLayout {
            id: tokenRow

            required property int index

            Layout.fillWidth: true
            spacing: Theme.spacingSmall

            TextField {
                id: tokenField

                Layout.fillWidth: true
                Layout.preferredHeight: 32
                font.pixelSize: Theme.fontSizeNormal
                font.family: Theme.fontFamilyMono
                color: Theme.foregroundColor
                selectionColor: Theme.accentColor
                placeholderText: tokenRow.index === 0 ? "terminal binary..." : "argument..."
                placeholderTextColor: Theme.mutedColor

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.backgroundColor
                    border.color: tokenField.activeFocus ? Theme.accentColor : Theme.borderColor
                    border.width: 1
                }

                // Text is set imperatively (a binding would fight typing).
                Component.onCompleted: tokenField.text = root._tokens[tokenRow.index] || ""
                onEditingFinished: root._commit(tokenRow.index, tokenField.text)
            }

            // Remove-token chip
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: Theme.radiusSmall
                color: removeArea.containsMouse ? Theme.surfaceColor : Theme.backgroundColor
                border.color: Theme.borderColor
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Theme.mutedColor
                    font.pixelSize: Theme.fontSizeNormal
                }
                MouseArea {
                    id: removeArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: root._remove(tokenRow.index)
                }
            }
        }
    }

    // Add-token chip
    Rectangle {
        Layout.preferredHeight: 26
        Layout.preferredWidth: addLabel.implicitWidth + 20
        Layout.leftMargin: Theme.paddingSmall
        radius: Theme.radiusSmall
        color: addArea.containsMouse ? Theme.surfaceColor : Theme.backgroundColor
        border.color: Theme.borderColor
        border.width: 1

        Text {
            id: addLabel

            anchors.centerIn: parent
            text: "+ Add Argument"
            color: Theme.foregroundColor
            font.pixelSize: Theme.fontSizeSmall
        }
        MouseArea {
            id: addArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root._tokens = root._tokens.concat([""]);
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 11
        Layout.preferredHeight: 1
        color: Theme.glassBorder
    }
}

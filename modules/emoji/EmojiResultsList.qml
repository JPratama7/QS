pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services/system"

Item {
    id: list

    implicitHeight: resultsView.contentHeight || 100

    ListView {
        id: resultsView
        anchors.fill: parent
        visible: Emoji.hasResults
        model: Emoji.results
        delegate: resultDelegate
        spacing: Theme.spacingSmall
        clip: true

        highlight: Rectangle {
            color: Qt.alpha(Theme.accentColor, 0.2)
            radius: Theme.radiusSmall
        }
        highlightFollowsCurrentItem: true
        currentIndex: Emoji.selectedIndex
    }

    Component {
        id: resultDelegate

        Rectangle {
            id: resultRow
            required property var modelData
            required property int index

            width: resultsView.width
            height: glyphText.implicitHeight + Theme.paddingSmall * 2
            radius: Theme.radiusSmall
            color: resultRow.index === Emoji.selectedIndex
                ? Qt.alpha(Theme.accentColor, 0.15)
                : "transparent"

            Row {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }
                spacing: Theme.spacingSmall

                Text {
                    id: glyphText
                    width: 36
                    text: resultRow.modelData.c
                    font.pixelSize: 24          // larger than Theme.fontSizeLarge (15)
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.foregroundColor
                }
                Text {
                    width: parent.width - glyphText.width - parent.spacing
                    text: resultRow.modelData.n
                    color: Theme.foregroundColor
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: Emoji.selectedIndex = resultRow.index
                onClicked: {
                    Emoji.selectedIndex = resultRow.index;
                    Emoji.activateSelected();
                }
            }
        }
    }

    // Empty state when query has no matches
    Text {
        anchors.centerIn: parent
        text: "No results"
        color: Theme.mutedColor
        font.pixelSize: Theme.fontSizeNormal
        font.family: Theme.fontFamily
        visible: !Emoji.hasResults && Emoji.query !== ""
    }
}

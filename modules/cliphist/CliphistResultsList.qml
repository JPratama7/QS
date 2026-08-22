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
        visible: Cliphist.hasResults
        model: Cliphist.results
        delegate: resultDelegate
        spacing: Theme.spacingSmall
        clip: true

        highlight: Rectangle {
            color: Qt.alpha(Theme.accentColor, 0.2)
            radius: Theme.radiusSmall
        }
        highlightFollowsCurrentItem: true
        highlightMoveDuration: Theme.listHighlightDuration
        highlightResizeDuration: Theme.listHighlightDuration
        currentIndex: Cliphist.selectedIndex
    }

    Component {
        id: resultDelegate

        Rectangle {
            id: resultRow
            required property string modelData
            required property int index

            width: resultsView.width
            height: entryText.implicitHeight + Theme.paddingSmall * 2
            radius: Theme.radiusSmall
            color: resultRow.index === Cliphist.selectedIndex
                ? Qt.alpha(Theme.accentColor, 0.15)
                : "transparent"

            Text {
                id: entryText
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }
                // Strip the cliphist ID prefix (e.g. "1234\tActual content") for display
                text: {
                    const tab = resultRow.modelData.indexOf("\t");
                    return tab >= 0 ? resultRow.modelData.substring(tab + 1) : resultRow.modelData;
                }
                color: Theme.foregroundColor
                font.pixelSize: Theme.fontSizeSmall
                font.family: Theme.fontFamily
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: Cliphist.selectedIndex = resultRow.index
                onClicked: {
                    Cliphist.selectedIndex = resultRow.index;
                    Cliphist.activateSelected();
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
        visible: !Cliphist.hasResults && Cliphist.query !== ""
    }
}

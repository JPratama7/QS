pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "../../../config"
import "../shared"

Item {
    id: page

    required property string screenName
    required property StackView stackView

    // Pages embed rows inline via this alias; content implicitHeight drives page height.
    default property alias content: contentColumn.data

    readonly property int maxMenuHeight: PersistentConfig.adapter.trayMenuMaxHeight
    readonly property int headerHeight: backHeader.headerHeight
    readonly property int contentHeight: contentColumn.implicitHeight + Theme.paddingNormal * 2
    readonly property int totalHeight: headerHeight + contentHeight

    implicitWidth: width
    implicitHeight: Math.min(totalHeight, headerHeight + maxMenuHeight)

    BackHeader {
        id: backHeader

        stackView: page.stackView
        showWhenSubmenu: true
    }

    ScrollView {
        contentHeight: contentColumn.implicitHeight + Theme.paddingNormal
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        anchors {
            top: backHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: backHeader.visible ? Theme.spacingSmall : Theme.paddingNormal
        }
        Column {
            id: contentColumn

            spacing: 2

            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }
}

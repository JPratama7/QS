pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../config" as Config
import "../../components" as Components

Item {
    id: barContent
    objectName: "Bar"

    required property var screen

    anchors.fill: parent
    anchors.margins: Config.Theme.barPadding

    Component {
        id: widgetDelegate

        Components.WidgetColumn {
            id: delegateRoot

            required property string modelData

            bgColor: loader.item ? loader.item.containerColor : Config.Theme.widgetBg

            Loader {
                id: loader

                source: delegateRoot.modelData.charAt(0).toUpperCase() + delegateRoot.modelData.slice(1) + ".qml"
                onLoaded: {
                    if (item.hasOwnProperty("showBackground"))
                        item.showBackground = false;

                }
            }

        }

    }

    // Horizontal layout
    RowLayout {
        id: horizontalLayout

        anchors.fill: parent
        visible: Config.Config.isHorizontal
        spacing: Config.Theme.barSpacing

        // Left section
        Row {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            Repeater {
                model: Config.Config.layout.left || []
                delegate: widgetDelegate
            }

        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Center section
        Row {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Repeater {
                model: Config.Config.layout.center || []
                delegate: widgetDelegate
            }

        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // Right section
        Row {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            Repeater {
                model: Config.Config.layout.right || []
                delegate: widgetDelegate
            }

        }

    }

    // Vertical layout
    ColumnLayout {
        id: verticalLayout

        anchors.fill: parent
        visible: Config.Config.isVertical
        spacing: Config.Theme.barSpacing

        // Top section
        Column {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignTop

            Repeater {
                model: Config.Config.layout.left || []
                delegate: widgetDelegate
            }

        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Middle section
        Column {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: Config.Config.layout.center || []
                delegate: widgetDelegate
            }

        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Bottom section
        Column {
            spacing: Config.Theme.barSpacing
            Layout.alignment: Qt.AlignBottom

            Repeater {
                model: Config.Config.layout.right || []
                delegate: widgetDelegate
            }

        }

    }

}

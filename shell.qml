import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "components" as Components
import "config" as Config
import "services" as Services
import "widgets" as Widgets

// Main shell configuration
Scope {
    id: root

    // Force StateStore initialization early
    readonly property var stateStore: Services.StateStore

    Component.onCompleted: {
        Qt.application.name = "QuickshellBar";
        Qt.application.organization = "Quickshell";
        Qt.application.domain = "quickshell.org";
    }

    // Variants for multi-monitor support
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property var screen: modelData

            implicitHeight: Config.Config.isHorizontal ? Config.Config.barSize : 0
            implicitWidth: Config.Config.isVertical ? Config.Config.barSize : 0
            color: Config.Theme.bg
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Config.Config.barSize

            // Position based on config
            anchors {
                top: Config.Config.position === Config.Config.Position.Top || Config.Config.isVertical
                bottom: Config.Config.position === Config.Config.Position.Bottom || Config.Config.isVertical
                left: Config.Config.position === Config.Config.Position.Left || Config.Config.isHorizontal
                right: Config.Config.position === Config.Config.Position.Right || Config.Config.isHorizontal
            }

            // Main bar content
            Item {
                id: barContent

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

                            source: "widgets/" + delegateRoot.modelData.charAt(0).toUpperCase() + delegateRoot.modelData.slice(1) + ".qml"
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

        }

    }

}

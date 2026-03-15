import Quickshell
import Quickshell.Wayland

import QtQuick
import QtQuick.Layouts
import "config" as Config
import "widgets" as Widgets
import "components" as Components

// Main shell configuration
Scope {
    id: root

    // Variants for multi-monitor support
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            property var screen: modelData

            // Position based on config
            anchors {
                top: Config.Config.position === Config.Config.Position.Top || Config.Config.isVertical
                bottom: Config.Config.position === Config.Config.Position.Bottom || Config.Config.isVertical
                left: Config.Config.position === Config.Config.Position.Left || Config.Config.isHorizontal
                right: Config.Config.position === Config.Config.Position.Right || Config.Config.isHorizontal
            }

            implicitHeight: Config.Config.isHorizontal ? Config.Config.barSize : 0
            implicitWidth: Config.Config.isVertical ? Config.Config.barSize : 0

            color: Config.Theme.bg

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusiveZone: Config.Config.barSize

            // Main bar content
            Item {
                id: barContent

                anchors.fill: parent
                anchors.margins: Config.Theme.barPadding

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
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Workspaces {
                                visible: Config.Config.showWorkspaces
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.WindowTitle {
                                visible: Config.Config.showWindowTitle
                                showBackground: false
                            }
                        }
                    }

                    // Spacer
                    Item { Layout.fillWidth: true }

                    // Right section
                    Row {
                        spacing: Config.Theme.barSpacing
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.SystemMonitor {
                                visible: Config.Config.showSystemMonitor
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Network {
                                visible: Config.Config.showNetwork
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Bluetooth {
                                visible: Config.Config.showBluetooth
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Battery {
                                visible: Config.Config.showBattery
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Audio {
                                visible: Config.Config.showAudio
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Brightness {
                                visible: Config.Config.showBrightness
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: nightShiftWidget.nightModeActive ? Config.Theme.warning : Config.Theme.widgetBg
                            Widgets.NightShift {
                                id: nightShiftWidget
                                visible: Config.Config.showNightShift
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: caffeineWidget.caffeineActive ? Config.Theme.warning : Config.Theme.widgetBg
                            Widgets.Caffeine {
                                id: caffeineWidget
                                visible: Config.Config.showCaffeine
                                showBackground: false
                            }
                        }
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Clock {
                                visible: Config.Config.showClock
                                showBackground: false
                            }
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
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Workspaces {
                                visible: Config.Config.showWorkspaces
                                showBackground: false
                            }
                        }
                    }

                    // Spacer
                    Item { Layout.fillHeight: true }

                    // Bottom section
                    Column {
                        spacing: Config.Theme.barSpacing
                        Layout.alignment: Qt.AlignBottom
                        Components.WidgetColumn {
                            bgColor: Config.Theme.widgetBg
                            Widgets.Clock {
                                visible: Config.Config.showClock
                                showBackground: false
                            }
                        }
                    }
                }
            }
        }
    }
}

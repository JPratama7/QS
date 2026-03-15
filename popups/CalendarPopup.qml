import QtQuick
import "../config" as Config
import "../base" as Base

Base.BasePopup {
    id: root

    popupWidth: 300
    popupHeight: 350

    // Calendar content
    Column {
        anchors.fill: parent
        spacing: Config.Theme.spacing

        // Month header
        Row {
            width: parent.width
            height: 30

            Text {
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                font.family: Config.Theme.fontFamily
                font.pixelSize: Config.Theme.fontSizeLarge
                font.bold: true
                color: Config.Theme.fg
            }
        }

        // Day headers
        Row {
            width: parent.width
            height: 20

            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                Text {
                    width: parent.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.family: Config.Theme.fontFamily
                    font.pixelSize: Config.Theme.fontSizeSmall
                    color: Config.Theme.fgDark
                }
            }
        }

        // Calendar grid
        Grid {
            id: calendarGrid
            width: parent.width
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            property var currentDate: new Date()
            property int daysInMonth: {
                const d = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0)
                return d.getDate()
            }
            property int firstDayOfMonth: {
                const d = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
                return d.getDay()
            }

            Repeater {
                model: calendarGrid.firstDayOfMonth + calendarGrid.daysInMonth

                Rectangle {
                    width: (calendarGrid.width - 12) / 7
                    height: 30
                    radius: Config.Theme.borderRadius

                    property int dayNumber: index - calendarGrid.firstDayOfMonth + 1
                    property bool isCurrentDay: {
                        const today = new Date()
                        return dayNumber === today.getDate() &&
                               calendarGrid.currentDate.getMonth() === today.getMonth() &&
                               calendarGrid.currentDate.getFullYear() === today.getFullYear()
                    }
                    property bool isValidDay: dayNumber > 0 && dayNumber <= calendarGrid.daysInMonth

                    color: isCurrentDay ? Config.Theme.accent : (isValidDay && mouseArea.containsMouse ? Config.Theme.widgetBgHover : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: isValidDay ? dayNumber : ""
                        font.family: Config.Theme.fontFamily
                        font.pixelSize: Config.Theme.fontSizeNormal
                        color: isCurrentDay ? Config.Theme.fgBright : Config.Theme.fg
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }
        }
    }
}

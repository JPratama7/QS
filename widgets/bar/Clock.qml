pragma ComponentBehavior: Bound
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import QtQuick
import QtQuick.Layouts

Base.BaseWidget {
    id: root

    // Fetch values from Config or fallback to defaults
    property var widgetConfig: Config.Config.getWidgetConfig("clock", {
        "timeFormat": "HH:mm",
        "dateFormat": "dd/MM",
        "showDate": true,
        "showSeconds": false
    })
    property string timeFormat: widgetConfig.timeFormat
    property string dateFormat: widgetConfig.dateFormat
    property bool showDate: widgetConfig.showDate
    property bool showSeconds: widgetConfig.showSeconds

    hasPopup: true
    tooltipText: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
    implicitWidth: clockRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    popupComponent: Component {
        Base.BasePopup {
            popupWidth: 320
            popupHeight: 360

            contentComponent: Item {
                id: calendar
                anchors.fill: parent

                property date today: new Date()
                property int viewMonth: today.getMonth()
                property int viewYear: today.getFullYear()
                readonly property int firstDayOfWeek: Qt.locale().firstDayOfWeek % 7
                property var daysModel: []
                property int hoveredIndex: -1
                readonly property int navButtonSize: 32

                function changeMonth(delta) {
                    const next = new Date(viewYear, viewMonth + delta, 1)
                    viewYear = next.getFullYear()
                    viewMonth = next.getMonth()
                }

                function resetToToday() {
                    const current = new Date()
                    today = current
                    viewYear = current.getFullYear()
                    viewMonth = current.getMonth()
                }

                function rebuildDaysModel() {
                    const normalizedFirstDay = firstDayOfWeek
                    const firstOfMonth = new Date(viewYear, viewMonth, 1)
                    const lastOfMonth = new Date(viewYear, viewMonth + 1, 0)
                    const daysInMonth = lastOfMonth.getDate()

                    const leading = (firstOfMonth.getDay() - normalizedFirstDay + 7) % 7
                    const prevMonth = new Date(viewYear, viewMonth, 0)
                    const prevMonthDays = prevMonth.getDate()
                    const result = []

                    for (let i = 0; i < leading; i++) {
                        const day = prevMonthDays - leading + 1 + i
                        const date = new Date(viewYear, viewMonth - 1, day)
                        result.push(createDayObject(date, false))
                    }

                    for (let day = 1; day <= daysInMonth; day++) {
                        const date = new Date(viewYear, viewMonth, day)
                        result.push(createDayObject(date, true))
                    }

                    const trailing = (7 - (result.length % 7)) % 7
                    for (let i = 1; i <= trailing; i++) {
                        const date = new Date(viewYear, viewMonth + 1, i)
                        result.push(createDayObject(date, false))
                    }

                    daysModel = result
                }

                function createDayObject(date, inMonth) {
                    const isToday = date.getFullYear() === calendar.today.getFullYear()
                        && date.getMonth() === calendar.today.getMonth()
                        && date.getDate() === calendar.today.getDate()
                    return ({
                        "day": date.getDate(),
                        "month": date.getMonth(),
                        "year": date.getFullYear(),
                        "inMonth": inMonth,
                        "today": isToday
                    })
                }

                function qtDayFromZeroBased(day) {
                    return day === 0 ? Qt.Sunday : day
                }

                function dayLabel(index) {
                    const dayZero = (firstDayOfWeek + index) % 7
                    const qtDay = qtDayFromZeroBased(dayZero)
                    const name = Qt.locale().standaloneDayName(qtDay, Locale.ShortFormat)
                    return name.length > 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase()
                }

                function monthLabel() {
                    return Qt.formatDate(new Date(viewYear, viewMonth, 1), "MMMM yyyy")
                }

                Component.onCompleted: rebuildDaysModel()
                onViewMonthChanged: rebuildDaysModel()
                onViewYearChanged: rebuildDaysModel()
                onFirstDayOfWeekChanged: rebuildDaysModel()
                onTodayChanged: {
                    if (viewYear === today.getFullYear() && viewMonth === today.getMonth()) {
                        rebuildDaysModel()
                    }
                }

                Timer {
                    interval: 60000
                    repeat: true
                    running: true
                    onTriggered: calendar.today = new Date()
                }

                WheelHandler {
                    id: monthWheelHandler
                    target: calendar
                    onWheel: function(event) {
                        if (event.angleDelta.y > 0) {
                            calendar.changeMonth(-1)
                        } else if (event.angleDelta.y < 0) {
                            calendar.changeMonth(1)
                        }
                        event.accepted = true
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Config.Theme.paddingLarge
                    spacing: Config.Theme.spacingLarge

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Config.Theme.spacingLarge

                        Rectangle {
                            Layout.preferredWidth: calendar.navButtonSize
                            Layout.preferredHeight: calendar.navButtonSize
                            radius: calendar.navButtonSize / 2
                            color: Config.Theme.widgetBg
                            border.width: 1
                            border.color: Config.Theme.widgetBorder

                            Text {
                                anchors.centerIn: parent
                                text: "‹"
                                font.pixelSize: Config.Theme.fontSizeLarge
                                font.family: Config.Theme.fontFamily
                                color: Config.Theme.fg
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = Config.Theme.widgetBgHover
                                onExited: parent.color = Config.Theme.widgetBg
                                onClicked: calendar.changeMonth(-1)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: calendar.monthLabel()
                            font.family: Config.Theme.fontFamily
                            font.pixelSize: Config.Theme.fontSizeLarge
                            font.bold: true
                            color: Config.Theme.fg
                        }

                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: calendar.navButtonSize
                            radius: calendar.navButtonSize / 2
                            color: Config.Theme.widgetBg
                            border.width: 1
                            border.color: Config.Theme.widgetBorder

                            Text {
                                anchors.centerIn: parent
                                text: "Today"
                                font.family: Config.Theme.fontFamily
                                font.pixelSize: Config.Theme.fontSizeSmall
                                font.bold: true
                                color: Config.Theme.accent
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = Config.Theme.widgetBgHover
                                onExited: parent.color = Config.Theme.widgetBg
                                onClicked: calendar.resetToToday()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: calendar.navButtonSize
                            Layout.preferredHeight: calendar.navButtonSize
                            radius: calendar.navButtonSize / 2
                            color: Config.Theme.widgetBg
                            border.width: 1
                            border.color: Config.Theme.widgetBorder

                            Text {
                                anchors.centerIn: parent
                                text: "›"
                                font.pixelSize: Config.Theme.fontSizeLarge
                                font.family: Config.Theme.fontFamily
                                color: Config.Theme.fg
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = Config.Theme.widgetBgHover
                                onExited: parent.color = Config.Theme.widgetBg
                                onClicked: calendar.changeMonth(1)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Config.Theme.spacing

                        Repeater {
                            id: dayHeaderRepeater
                            model: 7
                            delegate: Text {
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                horizontalAlignment: Text.AlignHCenter
                                text: calendar.dayLabel(index)
                                font.family: Config.Theme.fontFamily
                                font.pixelSize: Config.Theme.fontSizeSmall
                                font.bold: true
                                color: Config.Theme.fgDark
                            }
                        }
                    }

                    GridLayout {
                        id: daysGrid
                        Layout.fillWidth: true
                        columnSpacing: Config.Theme.spacing
                        rowSpacing: Config.Theme.spacing
                        columns: 7

                        property real cellSize: (width - (columnSpacing * (columns - 1))) / columns

                        Repeater {
                            id: daysRepeater
                            model: calendar.daysModel
                            delegate: Item {
                                id: dayItem
                                required property var modelData
                                required property int index
                                Layout.preferredWidth: daysGrid.cellSize
                                Layout.preferredHeight: daysGrid.cellSize

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Config.Theme.borderRadius
                                    color: dayItem.modelData.today ? Config.Theme.accent : (calendar.hoveredIndex === dayItem.index && dayItem.modelData.inMonth ? Config.Theme.widgetBgHover : "transparent")
                                    border.width: dayItem.modelData.today ? 0 : 1
                                    border.color: Config.Theme.widgetBorder
                                    opacity: dayItem.modelData.inMonth ? 1 : 0.45

                                    Text {
                                        anchors.centerIn: parent
                                        text: dayItem.modelData.day
                                        font.family: Config.Theme.fontFamily
                                        font.pixelSize: Config.Theme.fontSizeNormal
                                        font.bold: dayItem.modelData.today
                                        color: dayItem.modelData.today ? Config.Theme.bg : (dayItem.modelData.inMonth ? Config.Theme.fg : Config.Theme.fgDark)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: calendar.hoveredIndex = dayItem.index
                                    onExited: calendar.hoveredIndex = -1
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Timer to update clock
    Timer {
        id: clockTimer

        interval: root.showSeconds ? 1000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
    }

    Column {
        id: clockRow

        anchors.centerIn: parent
        anchors.verticalCenterOffset: 1 // Fine tune vertical center
        spacing: 0

        Components.BarText {
            id: timeText

            text: Qt.formatDateTime(new Date(), root.timeFormat)
            color: Config.Theme.warning
            fontSize: Config.Theme.fontSizeSmall
            bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.BarText {
            id: dateText

            text: Qt.formatDateTime(new Date(), root.dateFormat)
            color: Config.Theme.warning
            fontSize: Config.Theme.fontSizeXSmall
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

}

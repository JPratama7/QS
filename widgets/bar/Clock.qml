pragma ComponentBehavior: Bound

import "../../types/widgets/bar" as BarTypes
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Base.BaseWidget {
    id: root
    objectName: "Clock"

    required property BarTypes.Sizes sizes

    // Fetch values from Config or fallback to defaults
    property var widgetConfig: Config.Config.getWidgetConfig("clock", {
        "timeFormat": "HH:mm",
        "dateFormat": "dd/MM",
        "showDate": true,
        "showSeconds": false,
        "showWeekNumbers": true,
        "firstDayOfWeek": 1
    })
    property string timeFormat: widgetConfig.timeFormat
    property string dateFormat: widgetConfig.dateFormat
    property bool showDate: widgetConfig.showDate
    property bool showSeconds: widgetConfig.showSeconds
    property bool showWeekNumbers: widgetConfig.showWeekNumbers ?? true
    property int firstDayOfWeek: widgetConfig.firstDayOfWeek ?? 1

    cachePolicy: Base.BaseWidget.CachePolicy.LazyCache

    tooltipText: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
    Binding on implicitWidth { value: clockRow.implicitWidth + (Config.Theme.widgetPadding * 2) }

    popupComponent: Component {
        Base.BasePopup {
            id: popupRoot
            popupWidth: root.showWeekNumbers ? 340 : 320
            popupHeight: 400

            backgroundComponent: Component {
                Rectangle {
                    id: popupBackground
                    radius: Config.Theme.paddingLarge
                    color: Config.Theme.widgetBg
                    border.width: 1
                    border.color: Config.Theme.widgetBorder
                }
            }

            contentComponent: Item {
                id: calendar
                anchors.fill: parent

                property date today: new Date()
                property date currentTime: new Date()
                property int viewMonth: today.getMonth()
                property int viewYear: today.getFullYear()

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

                function monthLabel() {
                    return Qt.formatDate(new Date(viewYear, viewMonth, 1), "MMMM yyyy")
                }

                function getISOWeekNumber(date) {
                    const target = new Date(date.valueOf())
                    const dayNr = (date.getDay() + 6) % 7
                    target.setDate(target.getDate() - dayNr + 3)
                    const firstThursday = new Date(target.getFullYear(), 0, 4)
                    const diff = target - firstThursday
                    const oneWeek = 1000 * 60 * 60 * 24 * 7
                    return 1 + Math.round(diff / oneWeek)
                }

                Timer {
                    id: minuteTimer
                    interval: 60000
                    repeat: true
                    running: true
                    onTriggered: {
                        calendar.today = new Date()
                        calendar.currentTime = new Date()
                    }
                }

                Timer {
                    id: secondTimer
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: calendar.currentTime = new Date()
                }

                WheelHandler {
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
                    id: mainLayout
                    anchors.fill: parent
                    anchors.margins: Config.Theme.padding
                    spacing: Config.Theme.padding

                    // Header Card - split into date and clock sections
                    RowLayout {
                        id: headerRow
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        Layout.minimumHeight: 72
                        spacing: Config.Theme.padding

                        // Date section
                        Rectangle {
                            id: dateSection
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Config.Theme.paddingLarge
                            color: Config.Theme.accent

                            ColumnLayout {
                                id: dateLayout
                                anchors.centerIn: parent
                                spacing: Config.Theme.spacing

                                Text {
                                    id: dayNumberText
                                    Layout.alignment: Qt.AlignHCenter
                                    text: calendar.today.getDate()
                                    font.family: Config.Theme.fontFamily
                                    font.pixelSize: root.sizes.textXLarge * 1.8
                                    font.bold: true
                                    color: Config.Theme.bg
                                }

                                RowLayout {
                                    id: monthYearRow
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: Config.Theme.spacing

                                    Text {
                                        id: monthNameText
                                        text: Qt.locale().standaloneMonthName(calendar.today.getMonth(), Locale.LongFormat).toUpperCase()
                                        font.family: Config.Theme.fontFamily
                                        font.pixelSize: root.sizes.textLarge
                                        font.bold: true
                                        color: Config.Theme.bg
                                    }

                                    Text {
                                        id: yearText
                                        text: calendar.today.getFullYear()
                                        font.family: Config.Theme.fontFamily
                                        font.pixelSize: root.sizes.text
                                        font.bold: true
                                        color: Qt.alpha(Config.Theme.bg, 0.7)
                                    }
                                }
                            }
                        }

                        // Clock section
                        Rectangle {
                            id: clockSection
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Config.Theme.paddingLarge
                            color: Config.Theme.accent

                            Column {
                                id: digitalClock
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    id: timeDisplay
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatTime(calendar.currentTime, "hh:mm:ss")
                                    font.family: Config.Theme.fontFamily
                                    font.pixelSize: root.sizes.textXLarge * 1.8
                                    font.bold: true
                                    color: Config.Theme.bg
                                }

                                Text {
                                    id: ampmDisplay
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: Qt.formatTime(calendar.currentTime, "AP")
                                    font.family: Config.Theme.fontFamily
                                    font.pixelSize: root.sizes.text
                                    font.bold: true
                                    color: Qt.alpha(Config.Theme.bg, 0.8)
                                }
                            }
                        }
                    }

                    // Month Card (caelestia-style with MonthGrid)
                    Rectangle {
                        id: monthCard
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 280
                        color: Config.Theme.widgetBg
                        radius: Config.Theme.paddingLarge

                        ColumnLayout {
                            id: monthLayout
                            anchors.fill: parent
                            anchors.margins: Config.Theme.paddingLarge
                            spacing: Config.Theme.spacingLarge

                            // Navigation row (caelestia-style)
                            RowLayout {
                                id: navigationRow
                                Layout.fillWidth: true
                                spacing: Config.Theme.spacing

                                Components.CalendarIconButton {
                                    id: prevMonthButton
                                    icon: "←"
                                    onClicked: calendar.changeMonth(-1)
                                }

                                Item {
                                    id: monthYearContainer
                                    Layout.fillWidth: true
                                    implicitWidth: monthYearDisplay.implicitWidth + Config.Theme.padding * 2
                                    implicitHeight: monthYearDisplay.implicitHeight + Config.Theme.padding

                                    Rectangle {
                                        id: todayButton
                                        anchors.fill: parent
                                        anchors.margins: -Config.Theme.spacing
                                        radius: Config.Theme.borderRadius
                                        color: todayMouseArea.containsMouse ? Qt.alpha(Config.Theme.accent, 0.1) : "transparent"
                                        visible: !(calendar.viewMonth === calendar.today.getMonth() && calendar.viewYear === calendar.today.getFullYear())

                                        Behavior on color {
                                            ColorAnimation { duration: Config.Theme.animationFast }
                                        }

                                        MouseArea {
                                            id: todayMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: calendar.resetToToday()
                                        }
                                    }

                                    Text {
                                        id: monthYearDisplay
                                        anchors.centerIn: parent
                                        text: calendar.monthLabel()
                                        font.family: Config.Theme.fontFamily
                                        font.pixelSize: root.sizes.text
                                        font.bold: true
                                        font.capitalization: Font.Capitalize
                                        color: Config.Theme.accent
                                    }
                                }

                                Components.CalendarIconButton {
                                    id: nextMonthButton
                                    icon: "→"
                                    onClicked: calendar.changeMonth(1)
                                }
                            }

                            RowLayout {
                                id: dayNamesRow
                                Layout.fillWidth: true
                                spacing: Config.Theme.spacing

                                DayOfWeekRow {
                                    id: dayOfWeekRow
                                    Layout.fillWidth: true
                                    locale: monthGrid.locale

                                    delegate: Text {
                                        required property var model
                                        horizontalAlignment: Text.AlignHCenter
                                        text: model.shortName
                                        font.family: Config.Theme.fontFamily
                                        font.pixelSize: root.sizes.textSmall
                                        font.bold: true
                                        color: (model.day === 0 || model.day === 6) ? Config.Theme.purple : Config.Theme.accent
                                    }
                                }
                            }

                            RowLayout {
                                id: calendarGridRow
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: Config.Theme.spacing

                                // Week numbers column
                                ColumnLayout {
                                    id: weekNumbersColumn
                                    visible: root.showWeekNumbers
                                    Layout.preferredWidth: 32
                                    Layout.fillHeight: true
                                    spacing: Config.Theme.spacing

                                    property var weekNumbers: {
                                        const weeks = []
                                        const firstOfMonth = new Date(calendar.viewYear, calendar.viewMonth, 1)
                                        const lastOfMonth = new Date(calendar.viewYear, calendar.viewMonth + 1, 0)
                                        const daysInMonth = lastOfMonth.getDate()
                                        const leading = (firstOfMonth.getDay() - root.firstDayOfWeek + 7) % 7
                                        const numWeeks = Math.ceil((leading + daysInMonth) / 7)
                                        for (let i = 0; i < numWeeks; i++) {
                                            const dayIndex = i * 7 - leading + 1
                                            const date = new Date(calendar.viewYear, calendar.viewMonth, dayIndex || 1)
                                            weeks.push(calendar.getISOWeekNumber(date))
                                        }
                                        return weeks
                                    }

                                    Repeater {
                                        id: weekNumbersRepeater
                                        model: parent.weekNumbers
                                        delegate: Item {
                                            id: itemRoot
                                            required property var modelData
                                            Layout.preferredWidth: 32
                                            Layout.fillHeight: true
                                            Layout.preferredHeight: Config.Config.textSize + Config.Theme.padding

                                            Text {
                                                id: weekNumberText
                                                anchors.centerIn: parent
                                                text: itemRoot.modelData
                                                font.family: Config.Theme.fontFamily
                                                font.pixelSize: root.sizes.textXSmall
                                                color: Qt.alpha(Config.Theme.accent, 0.7)
                                            }
                                        }
                                    }
                                }

                                // Month grid (caelestia-style)
                                MonthGrid {
                                    id: monthGrid
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    month: calendar.viewMonth
                                    year: calendar.viewYear
                                    locale: Qt.locale()
                                    spacing: Config.Theme.spacing

                                    delegate: Item {
                                        id: dayDelegate
                                        required property var model

                                        // Square cells based on text heigh
                                        implicitWidth: dayText.implicitHeight + Config.Theme.padding
                                        implicitHeight: dayText.implicitHeight + Config.Theme.padding

                                        readonly property bool isToday: model.today
                                        readonly property bool inMonth: model.month === monthGrid.month
                                        readonly property bool isWeekend: {
                                            const dayOfWeek = model.date.getUTCDay()
                                            return dayOfWeek === 0 || dayOfWeek === 6
                                        }

                                        // Today indicator background (caelestia-style)
                                        Rectangle {
                                            id: todayIndicator
                                            anchors.centerIn: parent
                                            width: dayText.implicitWidth + Config.Theme.padding
                                            height: dayText.implicitHeight + Config.Theme.padding
                                            radius: Config.Theme.borderRadius
                                            color: dayDelegate.isToday ? Config.Theme.accent : "transparent"
                                            visible: dayDelegate.isToday

                                            Behavior on scale {
                                                NumberAnimation { duration: Config.Theme.animationNormal; easing.type: Easing.OutCubic }
                                            }
                                        }

                                        Text {
                                            id: dayText
                                            anchors.centerIn: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            text: monthGrid.locale.toString(model.day)
                                            font.family: Config.Theme.fontFamily
                                            font.pixelSize: root.sizes.text
                                            font.bold: model.today
                                            color: {
                                                if (model.today) return Config.Theme.bg
                                                if (!dayDelegate.inMonth) return Config.Theme.fgDark
                                                if (dayDelegate.isWeekend) return Config.Theme.purple
                                                return Config.Theme.fg
                                            }
                                            opacity: dayDelegate.inMonth ? 1 : 0.4
                                        }

                                        MouseArea {
                                            id: dayMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.MiddleButton
                                            onClicked: calendar.resetToToday()
                                        }
                                    }
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
        spacing: 1

        Components.BarText {
            id: timeText

            text: Qt.formatDateTime(new Date(), root.timeFormat)
            color: Config.Theme.warning
            fontSize: root.sizes.textSmall
            bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Components.BarText {
            id: dateText

            text: Qt.formatDateTime(new Date(), root.dateFormat)
            color: Config.Theme.warning
            fontSize: root.sizes.textXSmall
            visible: root.showDate
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

}

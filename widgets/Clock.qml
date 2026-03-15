import QtQuick
import "../config" as Config
import "../base" as Base
import "../components" as Components

Base.BaseWidget {
    id: root

    // Fetch values from JSON config or fallback to defaults
    property var widgetConfig: Config.JsonConfig.getWidgetConfig("clock", {
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

    // Timer to update clock
    Timer {
        id: clockTimer
        interval: showSeconds ? 1000 : 60000
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

    // Calendar popup component
    popupComponent: Qt.createComponent("../popups/CalendarPopup.qml")
}

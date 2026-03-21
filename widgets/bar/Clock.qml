import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import QtQuick

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
    // Calendar popup component
    popupComponent: Qt.createComponent("../../popups/CalendarPopup.qml")

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

import QtQuick
import "../../../config"

Text {
    id: widget

    property int _seconds: 0

    function formatTime(): string {
        const date = new Date();
        const h = date.getHours();
        const m = date.getMinutes();
        return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
    }

    function formatDate(): string {
        const date = new Date();
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        return days[date.getDay()] + " " + date.getDate();
    }

    text: {
        widget._seconds; // dependency
        const date = new Date();
        const h = date.getHours();
        const m = date.getMinutes();
        const timeStr = (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m);
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        const dateStr = days[date.getDay()] + " " + date.getDate();
        return timeStr + " " + dateStr;
    }
    color: Theme.foregroundColor
    font.pixelSize: Theme.fontSizeNormal
    font.family: Theme.fontFamily
    verticalAlignment: Text.AlignVCenter

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            widget._seconds++;
        }
    }
}

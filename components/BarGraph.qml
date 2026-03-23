pragma ComponentBehavior: Bound
import QtQuick
import "../config" as Config

Item {
    id: root

    property var values: []  // Array of values for the graph
    property int maxPoints: 30
    property color color: Config.Theme.accent
    property color fillColor: Qt.rgba(color.r, color.g, color.b, 0.3)
    property int graphHeight: 20
    property int graphWidth: 60

    implicitWidth: graphWidth
    implicitHeight: graphHeight

    function addValue(value) {
        const newValues = values.slice()
        newValues.push(value)
        if (newValues.length > maxPoints) {
            newValues.shift()
        }
        values = newValues
        canvas.requestPaint()
    }

    function clearValues() {
        values = []
        canvas.requestPaint()
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (root.values.length < 2) return

            const maxVal = Math.max(...root.values, 1)
            const stepX = width / (root.maxPoints - 1)

            // Draw fill
            ctx.beginPath()
            ctx.moveTo(0, height)
            for (let i = 0; i < root.values.length; i++) {
                const x = i * stepX
                const y = height - (root.values[i] / maxVal) * height
                ctx.lineTo(x, y)
            }
            ctx.lineTo((root.values.length - 1) * stepX, height)
            ctx.closePath()
            ctx.fillStyle = root.fillColor
            ctx.fill()

            // Draw line
            ctx.beginPath()
            for (let i = 0; i < root.values.length; i++) {
                const x = i * stepX
                const y = height - (root.values[i] / maxVal) * height
                if (i === 0) {
                    ctx.moveTo(x, y)
                } else {
                    ctx.lineTo(x, y)
                }
            }
            ctx.strokeStyle = root.color
            ctx.lineWidth = 1.5
            ctx.stroke()
        }
    }
}

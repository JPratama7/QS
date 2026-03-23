pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../config" as Config

PopupWindow {
    id: root
    objectName: "Tooltip"

    // Content properties
    property string text: ""
    property var rows: null // Array of arrays for grid mode: [["col1", "col2"], ["row2col1", "row2col2"]]
    property bool isGridMode: rows !== null && Array.isArray(rows) && rows.length > 0
    property int columnCount: isGridMode && rows.length > 0 ? rows[0].length : 0

    // Positioning properties
    property string direction: "auto" // "auto", "left", "right", "top", "bottom"
    property int margin: Config.Theme.spacing // distance from target
    property int padding: Config.Theme.padding
    property int gridPaddingVertical: Config.Theme.spacing // extra vertical padding for grid mode
    property int maxWidth: 340

    // Timing properties
    property int delay: 0
    property int hideDelay: 0

    // Animation properties
    property int animationDuration: Config.Theme.animationFast
    property real animationScale: 0.85

    // Font properties
    property string fontFamily: Config.Theme.fontFamily
    property int fontSize: Config.Theme.fontSizeSmall

    // Internal properties
    property var targetItem: null
    property real anchorX: 0
    property real anchorY: 0
    property bool isPositioned: false
    property bool animatingOut: true
    property int screenWidth: 1920
    property int screenHeight: 1080
    property int screenX: 0
    property int screenY: 0

    visible: false
    color: "transparent"

    anchor.item: targetItem
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    // Timer for showing tooltip after delay
    Timer {
        id: showTimer
        interval: root.delay
        repeat: false
        onTriggered: root.positionAndShow()
    }

    // Timer for hiding tooltip after delay
    Timer {
        id: hideTimer
        interval: root.hideDelay
        repeat: false
        onTriggered: root.startHideAnimation()
    }

    // Show animation - parallel opacity + scale
    ParallelAnimation {
        id: showAnimation

        PropertyAnimation {
            target: tooltipContainer
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }

        PropertyAnimation {
            target: tooltipContainer
            property: "scale"
            from: root.animationScale
            to: 1.0
            duration: root.animationDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    // Hide animation - parallel opacity + scale
    ParallelAnimation {
        id: hideAnimation

        PropertyAnimation {
            target: tooltipContainer
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: root.animationDuration * 0.75 // Slightly faster hide
            easing.type: Easing.InCubic
        }

        PropertyAnimation {
            target: tooltipContainer
            property: "scale"
            from: 1.0
            to: root.animationScale
            duration: root.animationDuration * 0.75
            easing.type: Easing.InCubic
        }

        onFinished: root.completeHide()
    }

    // TextMetrics for grid column width calculation
    TextMetrics {
        id: cellMetrics
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
    }

    // Hidden text item for measuring row height
    Text {
        id: rowHeightMeasure
        visible: false
        text: "Ag"
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
    }

    // Calculate grid dimensions
    function calculateGridSize() {
        if (!rows || rows.length === 0)
            return { width: 0, height: 0 }

        const numCols = rows[0].length
        const numRows = rows.length
        let columnWidths = []

        // Find max width for each column
        for (let col = 0; col < numCols; col++) {
            let maxW = 0
            for (let row = 0; row < numRows; row++) {
                cellMetrics.text = rows[row][col] || ""
                if (cellMetrics.width > maxW)
                    maxW = cellMetrics.width
            }
            columnWidths.push(maxW)
        }

        // Calculate total width
        let totalWidth = 0
        for (let i = 0; i < columnWidths.length; i++)
            totalWidth += columnWidths[i]
        totalWidth += (numCols - 1) * Config.Theme.spacing

        // Calculate total height
        const rowHeight = rowHeightMeasure.implicitHeight
        const totalHeight = numRows * rowHeight

        return { width: totalWidth, height: totalHeight }
    }

    // Main show function
    function show(target, content, customDirection, showDelay, customFont) {
        if (!target || !content || content === "" || (Array.isArray(content) && content.length === 0))
            return

        root.delay = showDelay !== undefined ? showDelay : 0

        // Stop any running timers and animations
        hideTimer.stop()
        showTimer.stop()
        hideAnimation.stop()
        animatingOut = false

        // If already showing for a different target, hide immediately
        if (visible && targetItem !== target)
            hideImmediately()

        // Set content based on type
        if (Array.isArray(content)) {
            rows = content
            text = ""
        } else {
            text = content.replace(/\n/g, '<br>')
            rows = null
        }

        targetItem = target

        // Find the correct screen based on target's global position
        const targetGlobal = target.mapToGlobal(target.width / 2, target.height / 2)
        let foundScreen = false
        for (let i = 0; i < Quickshell.screens.length; i++) {
            const s = Quickshell.screens[i]
            if (targetGlobal.x >= s.x && targetGlobal.x < s.x + s.width &&
                targetGlobal.y >= s.y && targetGlobal.y < s.y + s.height) {
                screenWidth = s.width
                screenHeight = s.height
                screenX = s.x
                screenY = s.y
                foundScreen = true
                break
            }
        }

        // Initialize animation state
        tooltipContainer.opacity = 0.0
        tooltipContainer.scale = root.animationScale

        // Set direction
        direction = customDirection !== undefined ? customDirection : "auto"

        // Set font
        if (customFont !== undefined)
            fontFamily = customFont

        showTimer.start()
    }

    // Position and show the tooltip
    function positionAndShow() {
        if (!targetItem || !targetItem.parent)
            return

        // Calculate dimensions
        let contentWidth, contentHeight
        if (isGridMode) {
            const gridSize = calculateGridSize()
            contentWidth = gridSize.width
            contentHeight = gridSize.height
        } else {
            contentWidth = tooltipText.implicitWidth
            contentHeight = tooltipText.implicitHeight
        }

        const extraPad = isGridMode ? gridPaddingVertical : 0
        const tipWidth = Math.ceil(Math.min(contentWidth + ((padding + extraPad) * 2), maxWidth))
        root.implicitWidth = tipWidth

        const tipHeight = Math.ceil(contentHeight + ((padding + extraPad) * 2))
        root.implicitHeight = tipHeight

        // Get target's screen-relative position
        const targetGlobalAbs = targetItem.mapToGlobal(0, 0)
        const targetGlobal = {
            x: targetGlobalAbs.x - screenX,
            y: targetGlobalAbs.y - screenY
        }
        const targetWidth = targetItem.width
        const targetHeight = targetItem.height

        let newAnchorX = 0
        let newAnchorY = 0
        let selectedPosition = null

        if (direction === "auto") {
            // Calculate available space in each direction
            const spaceLeft = targetGlobal.x
            const spaceRight = screenWidth - (targetGlobal.x + targetWidth)
            const spaceTop = targetGlobal.y
            const spaceBottom = screenHeight - (targetGlobal.y + targetHeight)

            // Try positions in order of preference
            const positions = [
                { dir: "bottom", space: spaceBottom, x: (targetWidth - tipWidth) / 2, y: targetHeight + margin, fits: spaceBottom >= tipHeight + margin },
                { dir: "top", space: spaceTop, x: (targetWidth - tipWidth) / 2, y: -tipHeight - margin, fits: spaceTop >= tipHeight + margin },
                { dir: "right", space: spaceRight, x: targetWidth + margin, y: (targetHeight - tipHeight) / 2, fits: spaceRight >= tipWidth + margin },
                { dir: "left", space: spaceLeft, x: -tipWidth - margin, y: (targetHeight - tipHeight) / 2, fits: spaceLeft >= tipWidth + margin }
            ]

            // Find first position that fits
            for (let i = 0; i < positions.length; i++) {
                if (positions[i].fits) {
                    selectedPosition = positions[i]
                    break
                }
            }

            // If none fit perfectly, use position with most space
            if (!selectedPosition) {
                positions.sort((a, b) => b.space - a.space)
                selectedPosition = positions[0]
            }

            newAnchorX = selectedPosition.x
            newAnchorY = selectedPosition.y
        } else {
            // Manual direction positioning
            switch (direction) {
            case "left":
                newAnchorX = -tipWidth - margin
                newAnchorY = (targetHeight - tipHeight) / 2
                break
            case "right":
                newAnchorX = targetWidth + margin
                newAnchorY = (targetHeight - tipHeight) / 2
                break
            case "top":
                newAnchorX = (targetWidth - tipWidth) / 2
                newAnchorY = -tipHeight - margin
                break
            case "bottom":
                newAnchorX = (targetWidth - tipWidth) / 2
                newAnchorY = targetHeight + margin
                break
            }
        }

        // Adjust horizontal position to keep tooltip on screen
        const globalX = targetGlobal.x + newAnchorX
        const effectiveDir = direction === "auto" ? selectedPosition.dir : direction
        const isHorizontalTooltip = (effectiveDir === "top" || effectiveDir === "bottom")

        if (globalX < 0) {
            const adjustedX = -targetGlobal.x + margin
            if (isHorizontalTooltip) {
                newAnchorX = adjustedX
            } else {
                const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
                if (!wouldOverlap)
                    newAnchorX = adjustedX
            }
        } else if (globalX + tipWidth > screenWidth) {
            const adjustedX = screenWidth - targetGlobal.x - tipWidth - margin
            if (isHorizontalTooltip) {
                newAnchorX = adjustedX
            } else {
                const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
                if (!wouldOverlap)
                    newAnchorX = adjustedX
            }
        }

        // Adjust vertical position to keep tooltip on screen
        const globalY = targetGlobal.y + newAnchorY
        const isVerticalTooltip = (effectiveDir === "left" || effectiveDir === "right")

        if (globalY < 0) {
            const adjustedY = -targetGlobal.y + margin
            if (isVerticalTooltip) {
                newAnchorY = adjustedY
            } else {
                const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
                if (!wouldOverlap)
                    newAnchorY = adjustedY
            }
        } else if (globalY + tipHeight > screenHeight) {
            const adjustedY = screenHeight - targetGlobal.y - tipHeight - margin
            if (isVerticalTooltip) {
                newAnchorY = adjustedY
            } else {
                const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
                if (!wouldOverlap)
                    newAnchorY = adjustedY
            }
        }

        // Apply position
        anchorX = newAnchorX < 0 ? Math.floor(newAnchorX) : Math.round(newAnchorX)
        anchorY = newAnchorY < 0 ? Math.floor(newAnchorY) : Math.round(newAnchorY)
        isPositioned = true

        // Make visible and start animation
        root.visible = true
        showAnimation.start()
    }

    // Hide function
    function hide() {
        showTimer.stop()
        hideTimer.stop()

        if (hideDelay > 0 && visible && !animatingOut) {
            hideTimer.start()
        } else {
            startHideAnimation()
        }
    }

    function startHideAnimation() {
        if (!visible || animatingOut)
            return
        animatingOut = true
        showAnimation.stop()
        hideAnimation.start()
    }

    function completeHide() {
        visible = false
        animatingOut = false
        text = ""
        rows = null
        isPositioned = false
        tooltipContainer.opacity = 1.0
        tooltipContainer.scale = 1.0
    }

    function hideImmediately() {
        showTimer.stop()
        hideTimer.stop()
        showAnimation.stop()
        hideAnimation.stop()
        animatingOut = false
        completeHide()
    }

    // Update content function
    function updateContent(newContent) {
        if (visible && targetItem) {
            if (Array.isArray(newContent)) {
                rows = newContent
                text = ""
            } else {
                text = newContent.replace(/\n/g, '<br>')
                rows = null
            }
            Qt.callLater(repositionTooltip)
        }
    }

    function repositionTooltip() {
        if (!visible || !targetItem)
            return

        // Recalculate dimensions
        let contentWidth, contentHeight
        if (isGridMode) {
            const gridSize = calculateGridSize()
            contentWidth = gridSize.width
            contentHeight = gridSize.height
        } else {
            contentWidth = tooltipText.implicitWidth
            contentHeight = tooltipText.implicitHeight
        }

        const extraPad = isGridMode ? gridPaddingVertical : 0
        const tipWidth = Math.ceil(Math.min(contentWidth + ((padding + extraPad) * 2), maxWidth))
        root.implicitWidth = tipWidth

        const tipHeight = Math.ceil(contentHeight + ((padding + extraPad) * 2))
        root.implicitHeight = tipHeight

        // Recenter based on current direction
        const targetWidth = targetItem.width
        const targetHeight = targetItem.height
        let newAnchorX = anchorX
        let newAnchorY = anchorY

        if (anchorY > targetHeight / 2) {
            // Below target
            newAnchorX = (targetWidth - tipWidth) / 2
        } else if (anchorY < -tipHeight / 2) {
            // Above target
            newAnchorX = (targetWidth - tipWidth) / 2
        } else if (anchorX > targetWidth / 2) {
            // Right of target
            newAnchorY = (targetHeight - tipHeight) / 2
        } else if (anchorX < -tipWidth / 2) {
            // Left of target
            newAnchorY = (targetHeight - tipHeight) / 2
        }

        // Clamp to screen
        const targetGlobalAbs = targetItem.mapToGlobal(0, 0)
        const targetGlobal = { x: targetGlobalAbs.x - screenX, y: targetGlobalAbs.y - screenY }
        const globalX = targetGlobal.x + newAnchorX
        const globalY = targetGlobal.y + newAnchorY

        if (globalX < 0) newAnchorX = -targetGlobal.x + margin
        else if (globalX + tipWidth > screenWidth) newAnchorX = screenWidth - targetGlobal.x - tipWidth - margin

        if (globalY < 0) newAnchorY = -targetGlobal.y + margin
        else if (globalY + tipHeight > screenHeight) newAnchorY = screenHeight - targetGlobal.y - tipHeight - margin

        anchorX = newAnchorX < 0 ? Math.floor(newAnchorX) : Math.round(newAnchorX)
        anchorY = newAnchorY < 0 ? Math.floor(newAnchorY) : Math.round(newAnchorY)

        Qt.callLater(() => {
            if (root.anchor && root.visible)
                root.anchor.updateAnchor()
        })
    }

    // Reset function
    function reset() {
        showTimer.stop()
        hideTimer.stop()
        showAnimation.stop()
        hideAnimation.stop()

        visible = false
        animatingOut = false
        text = ""
        rows = null
        isPositioned = false
        direction = "auto"
        delay = 0
        hideDelay = 0

        tooltipContainer.opacity = 1.0
        tooltipContainer.scale = 1.0
    }

    // Tooltip content container for animations
    Item {
        id: tooltipContainer
        anchors.fill: parent

        opacity: 1.0
        scale: 1.0
        transformOrigin: Item.Center

        Rectangle {
            anchors.fill: parent
            anchors.margins: border.width
            color: Config.Theme.bgDark
            border.color: Config.Theme.fgMuted
            border.width: 1
            radius: Math.min(Config.Theme.borderRadius, Math.min(width, height) / 3)

            visible: root.text !== "" || root.isGridMode

            // Text content (default mode)
            Text {
                id: tooltipText
                visible: !root.isGridMode
                anchors.centerIn: parent
                anchors.margins: root.padding
                text: root.text
                font.family: root.fontFamily
                font.pixelSize: root.fontSize
                color: Config.Theme.fg
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                width: Math.min(implicitWidth, root.maxWidth - (root.padding * 2))
                textFormat: Text.RichText
            }

            // Grid content (grid mode)
            GridLayout {
                id: gridContent
                visible: root.isGridMode
                anchors.centerIn: parent
                columns: root.columnCount
                rowSpacing: 0
                columnSpacing: Config.Theme.spacing

                Repeater {
                    model: root.isGridMode ? [].concat.apply([], root.rows) : []

                    Text {
                        required property string modelData
                        text: modelData
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        color: Config.Theme.fg
                        Layout.preferredHeight: root.rowHeightMeasure.implicitHeight
                    }
                }
            }
        }
    }

    Component.onCompleted: reset()
    Component.onDestruction: reset()
}

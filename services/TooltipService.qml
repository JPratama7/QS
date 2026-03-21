import "../components" as Components
import QtQuick
import Quickshell
pragma Singleton

Singleton {
    // Convenience methods for common use cases

    id: root

    // Default timing
    property int defaultDelay: 500
    property int defaultHideDelay: 0
    // Current tooltip instance
    property var activeInstance: null
    property var pendingInstance: null
    // Component for creating tooltips
    property var tooltipComponent: Qt.createComponent("../components/Tooltip.qml")

    // Show tooltip for target with content
    // content: string (text mode) or array of arrays (grid mode)
    // direction: "auto", "left", "right", "top", "bottom"
    // delay: optional, uses defaultDelay if not specified
    function show(target, content, direction, delay, fontFamily) {
        if (!target || !content)
            return ;

        // Cancel any pending/active tooltips for different targets
        cancelForTarget(target);
        // Create new tooltip instance
        const instance = tooltipComponent.createObject(root);
        if (!instance) {
            console.error("TooltipService: Failed to create tooltip instance");
            return ;
        }
        pendingInstance = instance;
        // Use provided delay or default
        const showDelay = delay !== undefined ? delay : defaultDelay;
        // Show the tooltip
        instance.show(target, content, direction, showDelay, fontFamily);
        // Track as active once visible
        if (instance.visible) {
            activeInstance = instance;
            pendingInstance = null;
        } else {
            // Will become active after delay
            instance.visibleChanged.connect(() => {
                if (instance.visible && pendingInstance === instance) {
                    activeInstance = instance;
                    pendingInstance = null;
                }
            });
        }
        // Auto-cleanup when hidden
        instance.visibleChanged.connect(() => {
            if (!instance.visible && (activeInstance === instance || pendingInstance === instance))
                cleanupInstance(instance);

        });
    }

    // Hide current tooltip
    function hide() {
        if (activeInstance)
            activeInstance.hide();

        if (pendingInstance) {
            pendingInstance.hideImmediately();
            cleanupInstance(pendingInstance);
            pendingInstance = null;
        }
    }

    // Update content of active tooltip
    function updateContent(newContent) {
        if (activeInstance && activeInstance.visible)
            activeInstance.updateContent(newContent);

    }

    // Cancel tooltips for a specific target (or all if target is different)
    function cancelForTarget(target) {
        // Cancel pending instance
        if (pendingInstance) {
            pendingInstance.hideImmediately();
            cleanupInstance(pendingInstance);
            pendingInstance = null;
        }
        // Cancel active instance if it's for a different target
        if (activeInstance && activeInstance.targetItem !== target) {
            activeInstance.hideImmediately();
            cleanupInstance(activeInstance);
            activeInstance = null;
        }
    }

    // Cleanup instance
    function cleanupInstance(instance) {
        if (instance) {
            instance.reset();
            instance.destroy();
        }
    }

    // Show simple text tooltip
    function showText(target, text, direction, delay) {
        show(target, text, direction, delay);
    }

    // Show grid tooltip with rows
    function showGrid(target, rows, direction, delay, fontFamily) {
        show(target, rows, direction, delay, fontFamily);
    }

    // Show tooltip above target
    function showAbove(target, content, delay) {
        show(target, content, "top", delay);
    }

    // Show tooltip below target
    function showBelow(target, content, delay) {
        show(target, content, "bottom", delay);
    }

    // Show tooltip to the left of target
    function showLeft(target, content, delay) {
        show(target, content, "left", delay);
    }

    // Show tooltip to the right of target
    function showRight(target, content, delay) {
        show(target, content, "right", delay);
    }

}

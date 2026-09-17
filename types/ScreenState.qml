pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: state

    property bool hovered: false
    property bool popupOpen: false
    property bool forceVisible: false
    property bool fullscreen: false
    property string displayMode: "visible"

    readonly property bool effectiveVisible: {
        if (fullscreen && !popupOpen) return false;
        if (displayMode === "auto_hide") return hovered || popupOpen || forceVisible;
        return true;
    }
}

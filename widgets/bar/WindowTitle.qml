pragma ComponentBehavior: Bound
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import QtQuick
import Quickshell.Wayland

Base.BaseWidget {
    id: root
    objectName: "WindowTitle"

    property int maxWidth: 200
    property bool showAppName: true
    readonly property Toplevel activeToplevel: ToplevelManager.activeToplevel

    tooltipText: root.activeToplevel ? root.activeToplevel.title : "No active window"
    implicitWidth: Math.min(titleText.implicitWidth + (Config.Theme.widgetPadding * 2), maxWidth)

    Components.BarText {
        id: titleText

        anchors.centerIn: parent
        text: {
            if (!root.activeToplevel)
                return "";

            const title = root.activeToplevel.title || "";
            // Truncate if too long
            if (title.length > 30)
                return title.substring(0, 27) + "...";

            return title;
        }
        color: Config.Theme.fg
        fontSize: Config.Theme.fontSizeNormal
        maxWidth: root.maxWidth - (Config.Theme.widgetPadding * 2)
    }

}

pragma ComponentBehavior: Bound
import "../../types/widgets/bar" as BarTypes
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config
import "../../utils" as Utils
import QtQuick
import Quickshell.Wayland

Base.BaseWidget {
    id: root
    objectName: "WindowTitle"

    required property BarTypes.Sizes sizes

    property int maxWidth: 200
    property bool showAppName: true
    readonly property Toplevel activeToplevel: ToplevelManager.activeToplevel

    tooltipText: root.activeToplevel ? root.activeToplevel.title : "No active window"
    Binding on implicitWidth { value: Math.min(titleText.implicitWidth + (Config.Theme.widgetPadding * 2), root.maxWidth) }

    Components.BarIcon {
        id: barIcon
        anchors.left: parent.left
        anchors.leftMargin: Config.Theme.widgetPadding
        anchors.verticalCenter: parent.verticalCenter
        iconPath: {
            if (root.activeToplevel == null) {
                return Utils.AppIcon.iconForAppId("application-x-executable")
            }
            if (root.activeToplevel.appId == null) {
                return Utils.AppIcon.iconForAppId("", "application-x-executable")
            }

            return Utils.AppIcon.iconForAppId(root.activeToplevel.appId, "application-x-executable")
        }
    }

    Components.BarText {
        id: titleText

        anchors.left: barIcon.right
        anchors.leftMargin: Config.Theme.widgetPadding * 2
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
        fontSize: root.sizes.text
        maxWidth: root.maxWidth - (Config.Theme.widgetPadding * 2)
    }

}


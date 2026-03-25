pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import "../../base" as Base
import "../../config" as Config

Base.BasePopup {
    id: root

    // Override contentPadding to remove popup padding
    contentPadding: 0

    property SystemTrayItem trayItem: null
    property var anchorItem: null
    property var menu: trayItem?.menu || null
    property real anchorX: 0
    property real anchorY: 0

    property int menuItemHeight: 28
    property int menuItemSpacing: 2

    popupWidth: 220
    popupHeight: menuStack.currentItem ? menuStack.currentItem.implicitHeight : 200

    // Function to calculate popup height
    function calculatePopupHeight(itemCount: int, isSubMenu: bool): int {
        const totalItems = isSubMenu ? itemCount + 1 : itemCount; // +1 for back button
        return Math.round((totalItems * menuItemHeight) + Config.Theme.spacing);
    }

    backgroundComponent: Component {
        Rectangle {
            anchors.fill: parent
            color: Config.Theme.popupBg
            border.color: Config.Theme.popupBorder
            radius: 5
            
            // Dynamically adjust to content height with padding
            height: root.popupHeight
            width: root.popupWidth
        }
    }

    contentComponent: Item {}

    StackView {
        id: menuStack
        anchors.fill: parent
        anchors.margins: 0
        visible: root.visible

        QsMenuOpener {
            id: rootMenuOpener
            menu: root.menu

            onChildrenChanged: {
                if (children && children.length > 0) {
                    if (root.menu && menuStack.depth === 0) {
                        console.log("Pushed main menu (onChildrenChanged), depth:", menuStack.depth);
                        menuStack.push(subMenuComponent.createObject(menuStack, {
                            handle: root.menu,
                            isSubMenu: false
                        }));
                    }
                }
            }
        }

        Timer {
            id: menuLoadTimer
            interval: 200
            onTriggered: {
                if (rootMenuOpener.children && rootMenuOpener.children.length > 0) {
                    if (menuStack.depth === 0) {
                        menuStack.push(subMenuComponent.createObject(menuStack, {
                            handle: root.menu,
                            isSubMenu: false
                        }));
                    }
                } else {
                    // Push submenu anyway for menus that don't populate children immediately
                    if (root.menu && menuStack.depth === 0) {
                        menuStack.push(subMenuComponent.createObject(menuStack, {
                            handle: root.menu,
                            isSubMenu: false
                        }));
                    }
                }
            }
        }

        // Popup height is now bound to currentItem.implicitHeight via the property binding above

        pushEnter: NoTransition {}
        pushExit: NoTransition {}
        popEnter: NoTransition {}
        popExit: NoTransition {}

        component NoTransition: Transition {
            NumberAnimation { duration: 0 }
        }
    }

    
    component SubMenu: Column {
        id: menuColumn

        required property var handle
        property bool isSubMenu: false
        property bool shown: false

        width: root.popupWidth
        spacing: 0

        // Back button for submenus - removed as it's now in repeater

        opacity: shown ? 1 : 0
        scale: shown ? 1 : 0.9

        Component.onCompleted: shown = true
        StackView.onActivating: shown = true
        StackView.onDeactivating: shown = false
        StackView.onRemoved: destroy()

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Behavior on scale {
            NumberAnimation { duration: 150 }
        }

        QsMenuOpener {
            id: menuOpener
            menu: menuColumn.handle
        }

        Repeater {
            model: menuColumn.handle && menuOpener.children ? [...(menuColumn.isSubMenu ? [{ isBackButton: true, text: "Back" }] : []), ...menuOpener.children.values] : []

            delegate: Rectangle {
                id: menuItem
                required property var modelData

                width: menuColumn.width
                height: menuItem.modelData?.isBackButton ? 28 : (menuItem.modelData?.isSeparator ? 8 : 28)
                color: itemMouseArea.containsMouse ? Config.Theme.widgetBgHover : "transparent"
                radius: 0
                visible: true

                // Back button content
                Row {
                    visible: menuItem.modelData?.isBackButton ?? false
                    anchors.fill: parent
                    anchors.leftMargin: Config.Theme.spacing
                    anchors.rightMargin: Config.Theme.spacing
                    spacing: Config.Theme.spacing
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "◀"
                        color: Config.Theme.fg
                        font.pixelSize: Config.Config.textSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Back"
                        color: Config.Theme.fg
                        font.pixelSize: Config.Config.textSizeSmall
                        font.family: Config.Theme.fontFamily
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - Config.Theme.padding
                    height: 1
                    color: Config.Theme.fgMuted
                    visible: menuItem.modelData?.isSeparator ?? false
                }

                Row {
                    visible: !(menuItem.modelData?.isBackButton ?? false)
                    anchors.left: parent.left
                    anchors.leftMargin: Config.Theme.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        visible: menuItem.modelData?.checkState !== Qt.Unchecked
                        text: menuItem.modelData?.checkState === Qt.Checked ? "✓" : "○"
                        color: Config.Theme.fg
                        font.pixelSize: Config.Config.textSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: menuItem.modelData?.text || ""
                        color: menuItem.modelData?.enabled ? Config.Theme.fg : Config.Theme.fgMuted
                        font.pixelSize: Config.Config.textSizeSmall
                        font.family: Config.Theme.fontFamily
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        visible: menuItem.modelData?.hasChildren ?? false
                        text: " ▶"
                        color: Config.Theme.fgDark
                        font.pixelSize: Config.Config.textSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: menuItem.modelData?.enabled ?? true

                    onClicked: {
                        if (menuItem.modelData && !menuItem.modelData.isSeparator) {
                            if (menuItem.modelData.isBackButton) {
                                menuStack.pop();
                            } else if (menuItem.modelData.hasChildren) {
                                try {
                                    const subMenuInstance = subMenuComponent.createObject(menuStack, {
                                        handle: menuItem.modelData,
                                        isSubMenu: true
                                    });
                                    if (subMenuInstance) {
                                        menuStack.push(subMenuInstance);
                                    } else {
                                        console.error("Failed to create submenu instance for:", menuItem.modelData.text || "unknown item");
                                    }
                                } catch (error) {
                                    console.error("Error creating submenu:", error, "for item:", menuItem.modelData);
                                }
                            } else {
                                // Only trigger for regular menu items (not submenus)
                                if (menuItem.modelData && !menuItem.modelData.isSeparator && !menuItem.modelData.hasChildren) {
                                    try {
                                        menuItem.modelData.triggered();
                                    } catch (error) {
                                        console.error("Error triggering menu item:", error);
                                    }
                                }
                                // Use visible=false instead of close() to avoid QEventLoop crash
                                root.close();
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subMenuComponent
        SubMenu {}
    }

    anchor {
        item: (root.anchorItem && root.anchorItem.Window) ? root.anchorItem : null
        rect.x: root.anchorItem && root.anchorItem.Window ? (root.anchorItem.width / 2) - (root.popupWidth / 2) + root.anchorX : 0
        rect.y: {
            if (!root.anchorItem || !root.anchorItem.Window) return 0
            return root.anchorItem.height + Config.Theme.spacing
        }
    }

    function showMenu(item: SystemTrayItem, anchor: Item): void {
        // Clear any existing submenu when showing a new menu
        if (menuStack.depth > 0) {
            menuStack.clear();
        }

        root.trayItem = item;
        root.anchorItem = anchor;
        root.menu = item?.menu || null;

        // Start timer for menu loading
        if (root.menu) {
            menuLoadTimer.start();
        }

        root.open(anchor);
    }

    function hideMenu(): void {
        root.close();
        root.trayItem = null;
        root.anchorItem = null;
    }
}

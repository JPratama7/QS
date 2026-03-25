pragma ComponentBehavior: Bound

import "../../types/widgets/bar" as BarTypes
import QtQuick
import Quickshell.Services.SystemTray
import "../../base" as Base
import "../../components" as Components
import "../../config" as Config

Base.BaseWidget {
    id: root
    objectName: "Tray"

    required property BarTypes.Sizes sizes

    cachePolicy: Base.BaseWidget.CachePolicy.NoCache

    // Tray-specific properties
    property var hiddenItems: []  // Blacklist items
    property var pinnedItems: []  // Items to show inline
    property bool hidePassive: true  // Hide passive status items
    property bool drawerEnabled: true  // Enable drawer for overflow

    // Filtered items
    property var filteredItems: []  // Items to show inline
    property var drawerItems: []    // Items to show in drawer

    // Watch for status changes
    readonly property var trayItems: SystemTray.items?.values || []

    Connections {
        target: SystemTray.items
        function onValuesChanged() {
            root.updateFilteredItems();
        }
    }

    Component.onCompleted: {
        root.updateFilteredItems();
    }

    function updateFilteredItems(): void {
        const newFiltered = [];
        const newDrawer = [];

        for (let i = 0; i < root.trayItems.length; i++) {
            const item = root.trayItems[i];
            if (!item)
                continue;

            const itemId = item.id || "";

            // Skip blacklisted items
            if (root.isHidden(itemId))
                continue;

            // Skip passive items if hidePassive is enabled (status 0 = Passive)
            if (root.hidePassive && item.status === 0)
                continue;

            // Check if pinned
            if (root.isPinned(itemId)) {
                newFiltered.push(item);
            } else {
                newDrawer.push(item);
            }
        }

        // If drawer is disabled, show all items inline
        if (!root.drawerEnabled) {
            root.filteredItems = newFiltered.concat(newDrawer);
            root.drawerItems = [];
        } else {
            root.filteredItems = newFiltered;
            root.drawerItems = newDrawer;
        }
    }

    function isHidden(id: string): bool {
        for (let i = 0; i < root.hiddenItems.length; i++) {
            if (id === root.hiddenItems[i])
                return true;
        }
        return false;
    }

    function isPinned(id: string): bool {
        for (let i = 0; i < root.pinnedItems.length; i++) {
            if (id === root.pinnedItems[i])
                return true;
        }
        return false;
    }

    // Visibility based on having items
    visible: root.filteredItems.length > 0 || root.drawerItems.length > 0

    implicitWidth: trayRow.implicitWidth + (Config.Theme.widgetPadding * 2)

    // Drawer toggle button
    function toggleDrawer(): void {
        root.togglePopup();
    }

    // Menu handling
    property var activeMenuItem: null
    property var activeMenuAnchor: null

    function showMenu(item: SystemTrayItem, anchor: Item): void {
        root.activeMenuItem = item;
        root.activeMenuAnchor = anchor;
        if (menuLoader.item && menuLoader.item.showMenu) {
            menuLoader.item.showMenu(item, anchor);
        }
    }

    function hideMenu(): void {
        if (menuLoader.item && menuLoader.item.hideMenu) {
            menuLoader.item.hideMenu();
        }
        root.activeMenuItem = null;
        root.activeMenuAnchor = null;
    }

    on_PopupOpenChanged: {
        if (!root._popupOpen) {
            // Close menu when drawer closes
            Qt.callLater(root.destroyPopup)
        }
    }

    // Drawer popup component
    popupComponent: Component {
        TrayDrawerPanel {
            id: drawerPanel
            sizes: root.sizes
            drawerItems: root.drawerItems
            onItemMenuRequested: function(item, anchor) {
                root.showMenu(item, anchor);
            }
        }
    }

    // Menu loader (separate from popup)
    Loader {
        id: menuLoader
        active: true
        asynchronous: true
        source: "TrayMenu.qml"
    }

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: Config.Theme.widgetSpacing

        // Inline tray items
        Repeater {
            model: root.filteredItems

            TrayItem {
                id: inlineItem
                sizes: root.sizes
                modelData: modelData
                showTooltip: true
                onMenuRequested: function(mouse) {
                    if (modelData.hasMenu && modelData.menu) {
                        root.showMenu(modelData, inlineItem);
                    }
                }
            }
        }

        // Drawer toggle (chevron)
        Components.BarIcon {
            id: drawerToggle
            visible: root.drawerEnabled && root.drawerItems.length > 0
            icon: root._popupOpen ? "󰅀" : "󰅂"  // Chevron up/down
            color: Config.Theme.fgDark
            size: root.sizes.icon

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.toggleDrawer()
                propagateComposedEvents: true
            }
        }
    }
}

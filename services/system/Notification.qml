pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property int unreadCount: trackedList.length

    readonly property list<Notification> trackedNotifications: trackedList

    property list<Notification> trackedList: []

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true

        onNotification: (notification) => {
            notification.tracked = true;
            root.trackedList.push(notification);
            root.trackedListChanged();
        }
    }

    function dismissAll(): void {
        const toClose = root.trackedList.slice();
        root.trackedList = [];
        for (const n of toClose) {
            n.dismiss();
        }
    }

    function dismiss(notification: Notification): void {
        root.trackedList = root.trackedList.filter(n => n !== notification);
        notification.dismiss();
    }
}

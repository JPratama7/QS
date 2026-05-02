pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../config"

Singleton {
    id: root

    readonly property int unreadCount: trackedList.length

    readonly property list<Notification> trackedNotifications: trackedList

    property list<Notification> trackedList: ([])

    // Toast queue — each entry: { notification: Notification, createdAt: int }
    property var toastQueue

    signal newNotificationReceived(notification: Notification)

    Component.onCompleted: {
        root.toastQueue = [];
    }

    enum ToastRemoveReason {
        Dismiss = 0,
        Expire = 1
    }


    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true

        onNotification: notification => {
            notification.tracked = true;
            root.trackedList.push(notification);
            root.trackedListChanged();
            root.newNotificationReceived(notification);
            root.addToast(notification);
        }
    }

    Timer {
        id: toastSweepTimer
        interval: 500
        repeat: true
        running: (root.toastQueue || []).length > 0

        onTriggered: {
            if (!root.toastQueue)
                return;
            const now = Date.now();
            const duration = ShellConfig.toastDurationMs;
            const before = root.toastQueue.length;
            root.toastQueue = root.toastQueue.filter(item => (now - item.createdAt) < duration);
        }
    }

    function dismissAll(): void {
        const toClose = root.trackedList.slice();
        root.trackedList = [];
        for (const n of toClose) {
            n.dismiss();
        }
    }

    function dismiss(notification: Notification, reason: int): void {
        if (reason === root.ToastRemoveReason.Expire) {
            notification.expire();
        } else if (reason === root.ToastRemoveReason.Dismiss) {
            notification.dismiss();
        } else {
            console.warn("Unknown dismiss reason:", reason);
            notification.dismiss();
        }
        root.trackedList = root.trackedList.filter(n => n !== notification);

    }

    function addToast(notification: Notification): void {
        const maxStack = ShellConfig.toastMaxStack;
        let queue = (root.toastQueue || []).slice();
        if (queue.length >= maxStack) {
            queue.shift();
        }
        queue.push({
            notification: notification,
            createdAt: Date.now()
        });
        root.toastQueue = queue;
    }

    function removeToast(notification: Notification): void {
        if (!root.toastQueue)
            return;
        let queue = root.toastQueue.slice();
        root.dismiss(notification, root.ToastRemoveReason.Expire);
        queue = queue.filter(item => item.notification !== notification);
        root.toastQueue = queue;
    }
}

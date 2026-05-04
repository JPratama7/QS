pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../config"

Singleton {
	id: root

	enum ToastRemoveReason {
		Dismiss = 0,
		Expire = 1
	}

	readonly property int unreadCount: trackedList.length
	readonly property list<Notification> trackedNotifications: trackedList
	property list<Notification> trackedList: ([])
	readonly property bool dndEnabled: ShellConfig.dndEnabled

	// Toast queue — each entry: { notification: Notification, createdAt: int }
	property var toastQueue: ([])

	signal newNotificationReceived(notification: Notification)

	function toggleDnd(): void {
		PersistentConfig.adapterView.dndEnabled = !PersistentConfig.adapterView.dndEnabled;
	}

	function dismissAll(): void {
		const toClose = root.trackedList.slice();
		root.trackedList = [];
		for (const n of toClose) {
			n.dismiss();
		}

		root.toastQueue = [];
	}
	function dismiss(notification: Notification): void {
		notification.dismiss();
		root.trackedList = root.trackedList.filter(n => n !== notification);
		root.toastQueue = root.toastQueue.filter(item => item.notification !== notification);
	}
	function addToast(notification: Notification): void {
		const maxStack = ShellConfig.toastMaxStack;
		if (maxStack <= 0)
			return;
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
		notification.expire();
		root.toastQueue = root.toastQueue.filter(item => item.notification !== notification);
	}

	// Enforce notification history cap — dismiss oldest overflow entries
	function _enforceHistoryCap(): void {
		const maxHistory = ShellConfig.notificationMaxHistory;
		if (maxHistory <= 0)
			return;
		let list = root.trackedList;
		while (list.length > maxHistory) {
			const oldest = list[0];
			oldest.dismiss();
			// Remove from toast queue as well to avoid dangling references
			root.toastQueue = (root.toastQueue || []).filter(item => item.notification !== oldest);
			list = list.slice(1);
		}
		if (list !== root.trackedList)
			root.trackedList = list;
	}

	Component.onCompleted: {
		root.toastQueue = [];
	}

	NotificationServer {
		id: server

		actionsSupported: true
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		imageSupported: true
		keepOnReload: false

		onNotification: notification => {
			notification.tracked = true;
			root.trackedList.push(notification);
			root.trackedListChanged();
			root._enforceHistoryCap();
			root.newNotificationReceived(notification);
			if (!ShellConfig.dndEnabled) {
				root.addToast(notification);
			}
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
			root.toastQueue = root.toastQueue.filter(item => (now - item.createdAt) < duration);
		}
	}
}

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
	// Persisted via PersistentProperties for reload survival
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
		persist.toastQueue = [];
		toastSweepTimer.scheduleNext();
	}
	function dismiss(notification: Notification): void {
		notification.dismiss();
		root.trackedList = root.trackedList.filter(n => n !== notification);
		const filtered = root.toastQueue.filter(item => item.notification !== notification);
		root.toastQueue = filtered;
		persist.toastQueue = filtered;
		toastSweepTimer.scheduleNext();
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
		persist.toastQueue = queue;
		toastSweepTimer.scheduleNext();
	}
	function removeToast(notification: Notification): void {
		if (!root.toastQueue)
			return;
		notification.expire();
		const filtered = root.toastQueue.filter(item => item.notification !== notification);
		root.toastQueue = filtered;
		persist.toastQueue = filtered;
		toastSweepTimer.scheduleNext();
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
		persist.toastQueue = root.toastQueue;
		toastSweepTimer.scheduleNext();
	}

	Component.onCompleted: {
		root.toastQueue = persist.toastQueue || [];
		toastSweepTimer.scheduleNext();
	}

	NotificationServer {
		id: server

		actionsSupported: true
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		imageSupported: true
		keepOnReload: true

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

		function scheduleNext(): void {
			const queue = root.toastQueue;
			if (!queue || queue.length === 0) {
				running = false;
				return;
			}
			const now = Date.now();
			const duration = ShellConfig.toastDurationMs;
			let earliest = Infinity;
			for (const item of queue) {
				const remaining = (item.createdAt + duration) - now;
				if (remaining < earliest)
					earliest = remaining;
			}
			interval = Math.max(1, earliest);
			running = true;
		}

		repeat: false

		onTriggered: {
			const now = Date.now();
			const duration = ShellConfig.toastDurationMs;
			const filtered = root.toastQueue.filter(item => (now - item.createdAt) < duration);
			if (filtered.length !== root.toastQueue.length) {
				root.toastQueue = filtered;
				persist.toastQueue = filtered;
			}
			scheduleNext();
		}
	}
	PersistentProperties {
		id: persist

		property var toastQueue: ([])

		reloadableId: "notification-toast"
	}
}

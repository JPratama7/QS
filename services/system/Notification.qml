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

	// Cached earliest expiry timestamp — avoids O(N) scan in scheduleNext()
	property real _earliestExpiry: 0

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
		root._earliestExpiry = 0;
		root._schedulePersist();
		toastSweepTimer.running = false;
	}
	function dismiss(notification: Notification): void {
		notification.dismiss();
		root.trackedList = root.trackedList.filter(n => n !== notification);
		root.toastQueue = root.toastQueue.filter(item => item.notification !== notification);
		root._recomputeEarliestExpiry();
		root._schedulePersist();
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
		const now = Date.now();
		const expiresAt = now + ShellConfig.toastDurationMs;
		queue.push({
			notification: notification,
			createdAt: now
		});
		root.toastQueue = queue;
		root._earliestExpiry = (!root._earliestExpiry || expiresAt < root._earliestExpiry) ? expiresAt : root._earliestExpiry;
		root._schedulePersist();
		toastSweepTimer.scheduleNext();
	}
	function removeToast(notification: Notification): void {
		if (!root.toastQueue)
			return;
		notification.expire();
		root.toastQueue = root.toastQueue.filter(item => item.notification !== notification);
		root._recomputeEarliestExpiry();
		root._schedulePersist();
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
		root._recomputeEarliestExpiry();
		root._schedulePersist();
		toastSweepTimer.scheduleNext();
	}

	// Recompute _earliestExpiry from current queue (after removals)
	function _recomputeEarliestExpiry(): void {
		const queue = root.toastQueue;
		if (!queue || queue.length === 0) {
			root._earliestExpiry = 0;
			return;
		}
		const duration = ShellConfig.toastDurationMs;
		let earliest = Infinity;
		for (const item of queue) {
			const expiresAt = item.createdAt + duration;
			if (expiresAt < earliest)
				earliest = expiresAt;
		}
		root._earliestExpiry = earliest;
	}

	// Debounce persist writes — coalesces rapid successive mutations
	function _schedulePersist(): void {
		persistDebounce.restart();
	}

	Component.onCompleted: {
		root.toastQueue = persist.toastQueue || [];
		root._recomputeEarliestExpiry();
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
			const remaining = root._earliestExpiry - Date.now();
			if (remaining <= 0) {
				// Already expired — fire immediately
				interval = 1;
			} else {
				interval = remaining;
			}
			restart();
		}

		repeat: false

		onTriggered: {
			const now = Date.now();
			const duration = ShellConfig.toastDurationMs;
			const filtered = root.toastQueue.filter(item => (now - item.createdAt) < duration);
			if (filtered.length !== root.toastQueue.length) {
				root.toastQueue = filtered;
				root._recomputeEarliestExpiry();
				root._schedulePersist();
			}
			scheduleNext();
		}
	}
	Timer {
		id: persistDebounce

		interval: 50
		repeat: false

		onTriggered: {
			persist.toastQueue = root.toastQueue;
		}
	}
	PersistentProperties {
		id: persist

		property var toastQueue: ([])

		reloadableId: "notification-toast"
	}
}

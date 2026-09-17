pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../config"

Singleton {
	id: root

	property var allTimezones: ([])
	property string _buffer: ""
	property string systemTimezone: ""
	property string _lastSetTimezone: ""
	property string _setTzError: ""

	signal timezoneSetSuccess(string timeZone)
	signal timezoneSetFailed(string timeZone, string error)

	function setSystemTimezone(timeZone) {
		if (timeZone === "") {
			return;
		}
		root._lastSetTimezone = timeZone;
		root._setTzError = "";
		setTzProcess.command = ["timedatectl", "set-timezone", timeZone];
		setTzProcess.running = true;
	}
	function formatTime(dateTime, formatHint, timeZone) {
		// Without a configured timezone the system zone applies — Qt's formatter handles it.
		// Note: this QML engine has no Intl, so the timezone-aware path below is guarded.
		if (!timeZone || typeof Intl === 'undefined') {
			return Qt.formatDateTime(dateTime, formatHint);
		}
		const jsDate = new Date(dateTime.valueOf());
		try {
			// sv-SE gives zero-padded 24h "HH:mm"; weekday/AM-PM markers come from
			// en-US so the output reads consistently regardless of the system locale.
			switch (formatHint) {
			case "hh:mm":
				return jsDate.toLocaleString('sv-SE', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					hour12: false
				});
			case "hh:mm ddd":
				return jsDate.toLocaleString('sv-SE', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					hour12: false
				}) + " " + jsDate.toLocaleString('en-US', {
					timeZone: timeZone,
					weekday: 'short'
				});
			case "hh:mm:ss":
				return jsDate.toLocaleString('sv-SE', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					second: '2-digit',
					hour12: false
				});
			case "hh:mm AP":
				return jsDate.toLocaleString('en-US', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					hour12: true
				});
			case "MMM d, hh:mm":
				return jsDate.toLocaleString('en-US', {
					timeZone: timeZone,
					month: 'short',
					day: 'numeric'
				}) + ", " + jsDate.toLocaleString('sv-SE', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					hour12: false
				});
			default:
				return Qt.formatDateTime(dateTime, formatHint);
			}
		} catch (e) {
			return Qt.formatDateTime(dateTime, formatHint);
		}
	}
	function getToday(timeZone) {
		const now = new Date();
		if (!timeZone || typeof Intl === 'undefined') {
			return {
				year: now.getFullYear(),
				month: now.getMonth(),
				day: now.getDate()
			};
		}
		try {
			const parts = new Intl.DateTimeFormat('en-US', {
				timeZone: timeZone,
				year: 'numeric',
				month: 'numeric',
				day: 'numeric'
			}).formatToParts(now);
			return {
				year: parseInt(parts.find(p => p.type === 'year').value),
				month: parseInt(parts.find(p => p.type === 'month').value) - 1,
				day: parseInt(parts.find(p => p.type === 'day').value)
			};
		} catch (e) {
			return {
				year: now.getFullYear(),
				month: now.getMonth(),
				day: now.getDate()
			};
		}
	}
	function _applyDetectedTimezone() {
		if (!PersistentConfig.readyToWrite)
			return;
		if (PersistentConfig.adapterView.timeZone === "") {
			PersistentConfig.adapterView.timeZone = root.systemTimezone;
		}
	}

	Component.onCompleted: {
		tzProcess.running = true;
		detectTzProcess.running = true;
	}

	Process {
		id: tzProcess

		command: ["timedatectl", "list-timezones"]

		stdout: SplitParser {
			onRead: data => {
				root._buffer += data + "\n";
			}
		}

		onRunningChanged: {
			if (!running) {
				const lines = root._buffer.split("\n").filter(l => l.trim() !== "");
				if (lines.length > 0) {
					root.allTimezones = lines;
				} else {
					console.error("TimeZone: timedatectl list-timezones returned no data");
				}
				root._buffer = "";
			}
		}
	}
	Connections {
		function onReadyToWriteChanged() {
			if (PersistentConfig.readyToWrite && root.systemTimezone !== "") {
				root._applyDetectedTimezone();
			}
		}

		target: PersistentConfig
	}
	Process {
		id: detectTzProcess

		command: ["timedatectl", "show", "-P", "Timezone"]

		stdout: SplitParser {
			onRead: data => {
				root.systemTimezone = data.trim();
			}
		}

		stderr: SplitParser {
			onRead: data => console.warn("TimeZone detect error:", data)
		}

		onRunningChanged: {
			if (!running && root.systemTimezone !== "") {
				root._applyDetectedTimezone();
			}
		}
	}
	Process {
		id: setTzProcess

		stderr: SplitParser {
			onRead: data => {
				root._setTzError += data;
			}
		}

		onRunningChanged: {
			if (!running) {
				if (root._setTzError !== "") {
					console.error("TimeZone: set-timezone failed:", root._setTzError);
					root.timezoneSetFailed(root._lastSetTimezone, root._setTzError);
				} else {
					root.timezoneSetSuccess(root._lastSetTimezone);
				}
				root._setTzError = "";
			}
		}
	}
}

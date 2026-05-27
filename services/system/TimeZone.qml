pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../config"

Singleton {
	id: root

	property var allTimezones: []
	property bool _loaded: false
	property string _buffer: ""
	property string systemTimezone: ""

	function setSystemTimezone(timeZone) {
		if (timeZone === "") {
			return;
		}
		setTzProcess.command = ["timedatectl", "set-timezone", timeZone];
		setTzProcess.running = true;
	}
	function formatTime(dateTime, formatHint, timeZone) {
		if (!timeZone || typeof Intl === 'undefined') {
			return Qt.formatDateTime(dateTime, formatHint);
		}
		try {
			const jsDate = new Date(dateTime.valueOf());
			if (formatHint === "hh:mm ddd") {
				const time = jsDate.toLocaleString('sv-SE', {
					timeZone: timeZone,
					hour: '2-digit',
					minute: '2-digit',
					hour12: false
				});
				const weekday = jsDate.toLocaleString('en-US', {
					timeZone: timeZone,
					weekday: 'short'
				});
				return time + " " + weekday;
			}
			return Qt.formatDateTime(dateTime, formatHint);
		} catch (e) {
			return Qt.formatDateTime(dateTime, formatHint);
		}
	}
	function getToday(timeZone) {
		if (!timeZone || typeof Intl === 'undefined') {
			const now = new Date();
			return {
				year: now.getFullYear(),
				month: now.getMonth(),
				day: now.getDate()
			};
		}
		try {
			const now = new Date();
			const formatter = new Intl.DateTimeFormat('en-US', {
				timeZone: timeZone,
				year: 'numeric',
				month: 'numeric',
				day: 'numeric'
			});
			if (formatter.formatToParts) {
				const parts = formatter.formatToParts(now);
				const year = parseInt(parts.find(p => p.type === 'year').value);
				const month = parseInt(parts.find(p => p.type === 'month').value) - 1;
				const day = parseInt(parts.find(p => p.type === 'day').value);
				return {
					year: year,
					month: month,
					day: day
				};
			}
			const str = now.toLocaleString('sv-SE', {
				timeZone: timeZone,
				year: 'numeric',
				month: 'numeric',
				day: 'numeric'
			});
			const parts = str.split(/[-/]/);
			if (parts.length === 3) {
				return {
					year: parseInt(parts[0]),
					month: parseInt(parts[1]) - 1,
					day: parseInt(parts[2])
				};
			}
			const fallback = new Date();
			return {
				year: fallback.getFullYear(),
				month: fallback.getMonth(),
				day: fallback.getDate()
			};
		} catch (e) {
			const fallback = new Date();
			return {
				year: fallback.getFullYear(),
				month: fallback.getMonth(),
				day: fallback.getDate()
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
				root._loaded = true;
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

		onRunningChanged: {
			if (!running && root.systemTimezone !== "") {
				root._applyDetectedTimezone();
			}
		}
	}
	Process {
		id: setTzProcess
	}
}

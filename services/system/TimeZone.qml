pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property var allTimezones: []
	property bool _loaded: false
	property string _buffer: ""
	readonly property var _fallbackTimezones: ["local", "UTC", "Africa/Cairo", "Africa/Johannesburg", "Africa/Lagos", "America/Anchorage", "America/Bogota", "America/Chicago", "America/Denver", "America/Lima", "America/Los_Angeles", "America/Mexico_City", "America/New_York", "America/Phoenix", "America/Sao_Paulo", "America/Toronto", "Asia/Bangkok", "Asia/Dubai", "Asia/Hong_Kong", "Asia/Jakarta", "Asia/Kolkata", "Asia/Manila", "Asia/Seoul", "Asia/Shanghai", "Asia/Singapore", "Asia/Taipei", "Asia/Tokyo", "Australia/Brisbane", "Australia/Melbourne", "Australia/Perth", "Australia/Sydney", "Europe/Amsterdam", "Europe/Athens", "Europe/Berlin", "Europe/Brussels", "Europe/Budapest", "Europe/Copenhagen", "Europe/Dublin", "Europe/Helsinki", "Europe/Istanbul", "Europe/Lisbon", "Europe/London", "Europe/Madrid", "Europe/Moscow", "Europe/Oslo", "Europe/Paris", "Europe/Prague", "Europe/Rome", "Europe/Stockholm", "Europe/Vienna", "Europe/Warsaw", "Europe/Zurich", "Pacific/Auckland", "Pacific/Honolulu"]

	function formatTime(dateTime, formatHint, timeZone) {
		if (!timeZone || timeZone === "local" || typeof Intl === 'undefined') {
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
		if (!timeZone || timeZone === "local" || typeof Intl === 'undefined') {
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

	Component.onCompleted: {
		tzProcess.running = true;
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
					root.allTimezones = ["local", ...lines];
				} else {
					root.allTimezones = root._fallbackTimezones;
				}
				root._buffer = "";
				root._loaded = true;
			}
		}
	}
}

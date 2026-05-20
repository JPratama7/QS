pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: service

	// CPU usage (0-1)
	property real cpuUsage: 0

	// RAM usage (0-1)
	property real ramUsage: 0

	// Temperature in Celsius
	property real temperature: 0

	// Raw values
	property int ramUsedMB: 0
	property int ramTotalMB: 0
	property real ramUsedGB: 0
	property real ramTotalGB: 0
	property bool useGB: false  // Auto-detected based on total RAM

	// Private state for CPU calculation
	property var _prevCpuStats: null

	function parseMemoryInfo(text: string): void {
		if (!text)
			return;
		const lines = text.split('\n');
		let memTotal = 0;
		let memAvailable = 0;

		for (const line of lines) {
			if (line.startsWith('MemTotal:')) {
				memTotal = parseInt(line.split(/\s+/)[1]) || 0;
			} else if (line.startsWith('MemAvailable:')) {
				memAvailable = parseInt(line.split(/\s+/)[1]) || 0;
			}
		}

		if (memTotal > 0) {
			const used = memTotal - memAvailable;
			service.ramTotalMB = Math.round(memTotal / 1024);
			service.ramUsedMB = Math.round(used / 1024);
			service.ramTotalGB = Math.round((memTotal / 1024 / 1024) * 10) / 10;
			service.ramUsedGB = Math.round((used / 1024 / 1024) * 10) / 10;
			service.ramUsage = used / memTotal;
			// Use GB if total RAM >= 1GB (1024 MB)
			service.useGB = service.ramTotalMB >= 1024;
		}
	}
	function parseCpuStat(text: string): void {
		if (!text)
			return;
		const lines = text.split('\n');
		const cpuLine = lines[0];

		if (!cpuLine.startsWith('cpu '))
			return;
		const parts = cpuLine.split(/\s+/);
		const stats = {
			user: parseInt(parts[1]) || 0,
			nice: parseInt(parts[2]) || 0,
			system: parseInt(parts[3]) || 0,
			idle: parseInt(parts[4]) || 0,
			iowait: parseInt(parts[5]) || 0,
			irq: parseInt(parts[6]) || 0,
			softirq: parseInt(parts[7]) || 0
		};

		const totalIdle = stats.idle + stats.iowait;
		const total = Object.values(stats).reduce((sum, val) => sum + val, 0);

		if (service._prevCpuStats) {
			const prevTotalIdle = service._prevCpuStats.idle + service._prevCpuStats.iowait;
			const prevTotal = Object.values(service._prevCpuStats).reduce((sum, val) => sum + val, 0);

			const diffTotal = total - prevTotal;
			const diffIdle = totalIdle - prevTotalIdle;

			if (diffTotal > 0) {
				service.cpuUsage = (diffTotal - diffIdle) / diffTotal;
			}
		}

		service._prevCpuStats = stats;
	}
	function parseTemp(text: string): void {
		if (!text)
			return;
		const temp = parseInt(text.trim());
		if (temp > 0) {
			service.temperature = temp > 1000 ? Math.round(temp / 1000) : temp;
		}
	}

	Timer {
		interval: 5000
		repeat: true
		running: true
		triggeredOnStart: true

		onTriggered: {
			memInfoFile.reload();
			cpuStatFile.reload();
			tempFile.reload();
		}
	}

	// RAM - /proc/meminfo
	FileView {
		id: memInfoFile

		path: "/proc/meminfo"

		onLoaded: service.parseMemoryInfo(text())
	}

	// CPU - /proc/stat
	FileView {
		id: cpuStatFile

		path: "/proc/stat"

		onLoaded: service.parseCpuStat(text())
	}

	// Temperature
	FileView {
		id: tempFile

		path: "/sys/class/thermal/thermal_zone0/temp"
		printErrors: false

		onLoaded: service.parseTemp(text())
		onLoadFailed: tempFile2.reload()
	}
	FileView {
		id: tempFile2

		path: "/sys/class/hwmon/hwmon0/temp1_input"
		printErrors: false

		onLoaded: service.parseTemp(text())
	}
}

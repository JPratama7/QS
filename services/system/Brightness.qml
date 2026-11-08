pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Backlight control via brightnessctl. The control center shows its slider
// only when a device is present (available === true) — brightnessctl may be
// missing or the machine may have no backlight (DESIGN_GUIDE.md §2).
Singleton {
    id: root

    // Whether a backlight device is reachable through brightnessctl
    readonly property bool available: root._available
    // Current brightness as a 0..1 fraction of the device maximum
    readonly property real percent: root._percent
    property bool _available: false
    property real _percent: 0

    // Internal — raw values and probe state
    property int _max: -1
    property int _current: -1
    property bool _setting: false
    property string _maxBuffer: ""
    property string _currentBuffer: ""

    function _parseInt(text: string): int {
        const value = parseInt(text.trim());
        return isNaN(value) ? -1 : value;
    }

    function _probe(): void {
        root._maxBuffer = "";
        root._currentBuffer = "";
        maxProcess.running = true;
    }

    // Set brightness to a 0..1 fraction; clamped to the device range.
    function setPercent(value: real): void {
        if (!root._available || root._setting)
            return;
        const clamped = Math.max(0, Math.min(1, value));
        const target = Math.round(clamped * 100);
        root._setting = true;
        setProcess.command = ["brightnessctl", "set", target + "%"];
        setProcess.running = true;
    }

    function _applyCurrent(): void {
        if (root._max > 0 && root._current >= 0) {
            root._percent = Math.max(0, Math.min(1, root._current / root._max));
        }
    }

    Process {
        id: maxProcess

        command: ["brightnessctl", "max"]

        stdout: SplitParser {
            onRead: data => root._maxBuffer += data
        }
        stderr: SplitParser {
            onRead: () => {
                root._available = false;
            }
        }

        onRunningChanged: {
            if (running)
                return;
            root._max = root._parseInt(root._maxBuffer);
            if (root._max <= 0) {
                root._available = false;
                return;
            }
            currentProcess.running = true;
        }
    }
    Process {
        id: currentProcess

        command: ["brightnessctl", "get"]

        stdout: SplitParser {
            onRead: data => root._currentBuffer += data
        }
        stderr: SplitParser {
            onRead: () => {
                root._available = false;
            }
        }

        onRunningChanged: {
            if (running)
                return;
            root._current = root._parseInt(root._currentBuffer);
            root._available = root._current >= 0;
            if (root._available)
                root._applyCurrent();
        }
    }
    Process {
        id: setProcess

        stderr: SplitParser {
            onRead: data => console.warn("Brightness: set failed:", data)
        }

        onRunningChanged: {
            if (!running) {
                root._setting = false;
                // Re-read to pick up the clamped device value
                root._probe();
            }
        }
    }

    Component.onCompleted: root._probe()
}

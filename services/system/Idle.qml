pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../config"

Singleton {
    id: root

    // Inhibition state - synced to/from PersistentConfig
    property bool inhibited: false

    // systemd-inhibit process - runs continuously while inhibited
    Process {
        id: systemdInhibitProcess
        command: ["systemd-inhibit", "--what", "idle:sleep", "--who", "quickshell", "--why", "User requested idle inhibition", "sleep", "infinity"]

        onRunningChanged: {
            console.log("Process running changed:", running, "processId:", processId)
            if (!running && root.inhibited) {
                // Process died while we wanted inhibition - restart it
                systemdInhibitProcess.running = true
            }
        }
    }

    // Restore state from persistence on startup
    Component.onCompleted: {
        restoreFromPersistence()
    }

    Connections {
        target: PersistentConfig
        function onAdapterChanged() {
            root.restoreFromPersistence()
        }
    }

    function restoreFromPersistence(): void {
        const persistedState = PersistentConfig.adapterView?.idleInhibitor ?? false
        if (persistedState !== inhibited) {
            if (persistedState)
                applyInhibit()
            else
                applyUninhibit()
        }
    }

    // Save state changes to persistence
    onInhibitedChanged: {
        if (PersistentConfig.adapterView)
            PersistentConfig.adapterView.idleInhibitor = inhibited
    }

    // Apply inhibition to backend using systemd-inhibit
    function applyInhibit(): void {
        console.log("Running inhibitor")
        systemdInhibitProcess.running = true
        inhibited = true
    }

    // Release inhibition from backend
    function applyUninhibit(): void {
        systemdInhibitProcess.running = false
        inhibited = false
    }

    // Public: Create idle inhibitor
    function inhibit(): void {
        applyInhibit()
    }

    // Public: Release idle inhibitor
    function uninhibit(): void {
        applyUninhibit()
    }

    // Toggle helper
    function toggle(): void {
        if (inhibited)
            uninhibit()
        else
            inhibit()
    }
}

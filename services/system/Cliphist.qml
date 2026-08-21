pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../ui"

Singleton {
    id: root

    // All raw entries from `cliphist list` (each line as-is, includes ID prefix)
    property var allEntries: ([])

    // Search query — filters allEntries
    property string query: ""

    // Filtered results (array of strings)
    readonly property var results: {
        const q = root.query.toLowerCase().trim();
        if (q === "")
            return root.allEntries;
        return root.allEntries.filter(e => e.toLowerCase().includes(q));
    }

    // Currently selected index in results
    property int selectedIndex: -1

    readonly property bool hasResults: root.results.length > 0

    readonly property string selectedEntry: {
        if (root.selectedIndex >= 0 && root.selectedIndex < root.results.length)
            return root.results[root.selectedIndex];
        return "";
    }

    // Accumulate stdout lines from `cliphist list`
    property string _listBuffer: ""

    // Process: cliphist list — collect all entries
    Process {
        id: listProcess
        command: ["cliphist", "list"]

        stdout: SplitParser {
            onRead: data => {
                root._listBuffer += data + "\n";
            }
        }

        stderr: SplitParser {
            onRead: data => console.warn("Cliphist list error:", data)
        }

        onRunningChanged: {
            if (!running) {
                const lines = root._listBuffer.split("\n").filter(l => l.trim() !== "");
                root.allEntries = lines;
                root._listBuffer = "";
                root.selectedIndex = lines.length > 0 ? 0 : -1;
            }
        }
    }

    // Process: decode selected entry and copy to clipboard via shell pipe
    Process {
        id: copyProcess
        command: ["sh", "-c", "cliphist decode | wl-copy"]
        stdinEnabled: true

        stderr: SplitParser {
            onRead: data => console.warn("Cliphist copy error:", data)
        }
    }

    // Refresh entries from cliphist
    function refresh(): void {
        root._listBuffer = "";
        listProcess.running = true;
    }

    // Open the cliphist popup on a given screen
    function open(screenName: string): void {
        root.query = "";
        root.selectedIndex = -1;
        root.refresh();
        ShellUI.openCliphist(screenName);
    }

    // Close the popup
    function close(): void {
        root.query = "";
        root.selectedIndex = -1;
        root.allEntries = [];
        ShellUI.closeCliphist();
    }

    // Toggle open/close
    function toggle(screenName: string): void {
        if (ShellUI.isCliphistOpen())
            root.close();
        else
            root.open(screenName);
    }

    // Move selection down
    function selectNext(): void {
        if (root.results.length === 0) return;
        root.selectedIndex = Math.min(root.selectedIndex + 1, root.results.length - 1);
    }

    // Move selection up
    function selectPrev(): void {
        if (root.results.length === 0) return;
        root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
    }

    // Copy selected entry to clipboard and close
    function activateSelected(): void {
        if (root.selectedEntry === "") return;
        root.copyEntry(root.selectedEntry);
        root.close();
    }

    // Copy a specific raw cliphist entry (with ID prefix) to clipboard
    function copyEntry(entry: string): void {
        copyProcess.stdinEnabled = true;
        copyProcess.running = true;
        copyProcess.write(entry + "\n");
        copyProcess.stdinEnabled = false; // close stdin → EOF → cliphist decode + wl-copy
    }

    onQueryChanged: {
        root.selectedIndex = root.results.length > 0 ? 0 : -1;
    }
}

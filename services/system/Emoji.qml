pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../ui"

Singleton {
    id: root

    // Raw dataset: [{ "c": "😀", "n": "grinning face", "k": ["face", "grin"] }, ...]
    property var allEmojis: ([])
    property bool _dataLoaded: false

    // Search query — empty query = browse mode (full list)
    property string query: ""

    // Filtered + ranked results
    readonly property var results: {
        const q = root.query.trim().toLowerCase();
        if (q === "")
            return root.allEmojis;
        const starts = [], contains = [], keyword = [];
        for (const e of root.allEmojis) {
            const n = e.n.toLowerCase();
            if (n.startsWith(q)) {
                starts.push(e);
            } else if (n.includes(q)) {
                contains.push(e);
            } else if ((e.k || []).some(k => k.toLowerCase().includes(q))) {
                keyword.push(e);
            }
        }
        return starts.concat(contains, keyword);
    }

    property int selectedIndex: -1
    readonly property bool hasResults: root.results.length > 0
    readonly property var selectedEmoji: {
        if (root.selectedIndex >= 0 && root.selectedIndex < root.results.length)
            return root.results[root.selectedIndex];
        return null;
    }

    // Data file loading (FileView + JSON.parse pattern, cf. PersistentConfig.qml:111-137)
    FileView {
        id: emojiFile
        path: Quickshell.shellDir + "/data/emojis.json"
        watchChanges: false
        onLoaded: {
            try {
                root.allEmojis = JSON.parse(emojiFile.text());
                root._dataLoaded = true;
                root.selectedIndex = root.allEmojis.length > 0 ? 0 : -1;
            } catch (e) {
                console.error("Emoji: failed to parse data/emojis.json:", e);
            }
        }
        onLoadFailed: error =>
            console.error("Emoji: failed to load data:", FileViewError.toString(error))
    }

    // Copy to clipboard — wl-copy reads stdin verbatim
    Process {
        id: copyProcess
        command: ["wl-copy"]
        stdinEnabled: true
        stderr: SplitParser {
            onRead: data => console.warn("Emoji copy error:", data)
        }
    }

    // Open the emoji popup on a given screen
    function open(screenName: string): void {
        if (!root._dataLoaded) {
            emojiFile.reload();
        }
        root.query = "";
        root.selectedIndex = -1;
        ShellUI.openEmoji(screenName);
    }

    // Close the popup
    function close(): void {
        root.query = "";
        root.selectedIndex = -1;
        ShellUI.closeEmoji();
    }

    // Toggle open/close
    function toggle(screenName: string): void {
        if (ShellUI.isEmojiOpen())
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

    // Copy selected emoji to clipboard and close
    function activateSelected(): void {
        if (root.selectedEmoji === null) return;
        root.copyEmoji(root.selectedEmoji.c);
        root.close();
    }

    // Copy a specific emoji to clipboard (no trailing newline — wl-copy verbatim)
    function copyEmoji(emoji: string): void {
        copyProcess.stdinEnabled = true;
        copyProcess.running = true;
        copyProcess.write(emoji);
        copyProcess.stdinEnabled = false; // close stdin → EOF → wl-copy copies + exits
    }

    onQueryChanged: {
        root.selectedIndex = root.results.length > 0 ? 0 : -1;
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"
import "../../services/system"

// IPC interface for the emoji picker.
// Usage: qs ipc call emoji <function>
//
// Functions:
//   toggleEmoji()               - Toggle emoji picker on primary screen
//   openEmoji(screen?: string)  - Open emoji picker (optional screen name)
//   closeEmoji()                - Close emoji picker
//   isEmojiOpen() -> bool       - Check if emoji picker is open
//
// Example keybind in keybindings.lua:
//   hl.bind(mainMod .. " + code:60", hl.dsp.exec_cmd("qs ipc call emoji toggleEmoji"))
IpcHandler {
    id: ipc

    target: "emoji"

    // Toggle emoji picker on primary screen
    function toggleEmoji(): void {
        if (ShellUI.isEmojiOpen()) {
            Emoji.close();
        } else {
            const screen = ShellConfig.primaryScreen
                || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
            Emoji.open(screen);
        }
    }

    // Open emoji picker on specified screen (or primary if omitted)
    function openEmoji(screen: string): void {
        const targetScreen = screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
        Emoji.open(targetScreen);
    }

    // Close emoji picker
    function closeEmoji(): void {
        Emoji.close();
    }

    // Query emoji picker state
    function isEmojiOpen(): bool {
        return ShellUI.isEmojiOpen();
    }
}

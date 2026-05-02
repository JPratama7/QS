pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"
import "../../services/system"

// IPC interface for cliphist clipboard manager popup.
// Usage: qs ipc call cliphist <function>
//
// Functions:
//   toggleCliphist()               - Toggle cliphist on primary screen
//   openCliphist(screen?: string)  - Open cliphist (optional screen name)
//   closeCliphist()                - Close cliphist
//   isCliphistOpen() -> bool       - Check if cliphist is open
//
// Example keybind in hyprland.conf:
//   bind = SUPER, V, exec, qs ipc call cliphist toggleCliphist
IpcHandler {
    id: ipc

    target: "cliphist"

    // Toggle cliphist on primary screen
    function toggleCliphist(): void {
        const screen = ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
        Cliphist.toggle(screen);
    }

    // Open cliphist on specified screen (or primary if omitted)
    function openCliphist(screen: string): void {
        const targetScreen = screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
        Cliphist.open(targetScreen);
    }

    // Close cliphist
    function closeCliphist(): void {
        Cliphist.close();
    }

    // Query cliphist state
    function isCliphistOpen(): bool {
        return ShellUI.isCliphistOpen();
    }
}

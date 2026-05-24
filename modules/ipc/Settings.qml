pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"

// Standard IPC interface for external control.
// Usage: qs ipc call settings <function>
//
// Functions:
//   toggleSettings()              - Toggle settings on primary screen
//   openSettings(screen?: string) - Open settings (optional screen name)
//   closeSettings()               - Close settings
//   isSettingsOpen() -> bool      - Check if settings is open
//
IpcHandler {
    id: ipc

    target: "settings"

    // Toggle settings on primary screen
    function toggleSettings(): void {
        if (ShellUI.isSettingsOpen()) {
            ShellUI.closeSettings();
        } else {
            const screen = ShellConfig.primaryScreen
                || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
            ShellUI.openSettings(screen);
        }
    }

    // Open settings on specified screen (or primary if omitted)
    function openSettings(screen: string): void {
        const targetScreen = screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
        ShellUI.openSettings(targetScreen);
    }

    // Close settings
    function closeSettings(): void {
        ShellUI.closeSettings();
    }

    // Query settings state
    function isSettingsOpen(): bool {
        return ShellUI.isSettingsOpen();
    }
}

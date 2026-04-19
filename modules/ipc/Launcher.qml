pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"
import "../../services/launcher"

// Standard IPC interface for external control.
// Usage: qs ipc call shell <function>
//
// Functions:
//   toggleLauncher()           - Toggle launcher on primary screen
//   openLauncher(screen?: string) - Open launcher (optional screen name)
//   closeLauncher()            - Close launcher
//   isLauncherOpen() -> bool   - Check if launcher is open
//
// Example keybind in hyprland.conf:
//   bind = SUPER, R, exec, qs ipc call shell toggleLauncher
IpcHandler {
    id: ipc

    target: "shell"

    // Toggle launcher on primary screen
    function toggleLauncher(): void {
        if (ShellUI.isLauncherOpen()) {
            Launcher.close();
        } else {
            const screen = ShellConfig.primaryScreen
                || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
            Launcher.open(screen);
        }
    }

    // Open launcher on specified screen (or primary if omitted)
    function openLauncher(screen: string): void {
        const targetScreen = screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
        Launcher.open(targetScreen);
    }

    // Close launcher
    function closeLauncher(): void {
        Launcher.close();
    }

    // Query launcher state
    function isLauncherOpen(): bool {
        return ShellUI.isLauncherOpen();
    }
}

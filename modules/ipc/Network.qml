pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"
import "../../services/system"

// IPC interface for the network manager popup.
// Usage: qs ipc call network <function>
//
// Functions:
//   toggleMenu()                 - Toggle network menu on primary screen
//   openMenu(screen?: string)    - Open network menu (optional screen name)
//   closeMenu(screen: string)    - Close network menu on specified screen
//   toggleWifi()                 - Toggle Wi-Fi on/off
//
// Example keybind in hyprland.conf:
//   bind = SUPER, N, exec, qs ipc call network toggleMenu
//
// Note: the menu component lives in NetworkMenuHost (popups/network),
// registered into PopupRegistry, because IpcHandler cannot hold object-typed
// properties — Quickshell rejects anything but void/string/int/bool/real/color
// over IPC. activeScreen must be set before openPopup() so the Loader-created
// NetworkMenu picks up the right screen.
IpcHandler {
    id: ipc

    target: "network"

    // Resolve a screen name: explicit arg → primary → first enabled screen → "".
    function _resolveScreen(screen: string): string {
        return screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
    }

    // Toggle network menu on the primary screen
    function toggleMenu(): void {
        const screen = ipc._resolveScreen("");
        if (screen === "")
            return;
        if (ShellUI.isPopupOpen(screen, "network")) {
            ShellUI.closePopup(screen);
        } else {
            ipc.openMenu(screen);
        }
    }

    // Open network menu on specified screen (or primary if omitted)
    function openMenu(screen: string): void {
        const targetScreen = ipc._resolveScreen(screen);
        if (targetScreen === "")
            return;
        PopupRegistry.activeScreen = targetScreen;
        const shellScreen = ScreenRegistry.screenByName(targetScreen);
        // 130 = NetworkMenu.menuWidth (260) / 2 — centers the menu on the bar
        const anchorX = shellScreen ? Math.max(0, Math.round(shellScreen.width / 2 - 130)) : 0;
        ShellUI.openPopup(targetScreen, "network", PopupRegistry.get("network"), anchorX);
    }

    // Close network menu on the specified screen
    function closeMenu(screen: string): void {
        const targetScreen = ipc._resolveScreen(screen);
        if (targetScreen === "")
            return;
        ShellUI.closePopup(targetScreen);
    }

    // Toggle Wi-Fi on/off
    function toggleWifi(): void {
        Network.toggleWifi();
    }
}

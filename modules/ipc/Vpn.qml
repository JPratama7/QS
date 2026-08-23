pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../config"
import "../../services/ui"
import "../../services/system"

// IPC interface for the VPN manager popup.
// Usage: qs ipc call vpn <function>
//
// Functions:
//   toggleMenu()                 - Toggle VPN menu on primary screen
//   openMenu(screen?: string)    - Open VPN menu (optional screen name)
//   closeMenu()                  - Close VPN menu
//   isMenuOpen() -> bool         - Check if the VPN menu is open
//   isConnected() -> bool        - Whether any VPN is connected
//   connectedNames() -> var      - Names of currently connected configs
//   disconnectAll()              - Disconnect every connected VPN (shell-side only)
//
// Example keybind in hyprland.conf:
//   bind = SUPER, V, exec, qs ipc call vpn toggleMenu
//
// Note: the menu component lives in VpnMenuHost (popups/vpn), registered into
// PopupRegistry, because IpcHandler cannot hold object-typed properties —
// Quickshell rejects anything but void/string/int/bool/real/color over IPC.
// activeScreen must be set before openPopup() so the Loader-created VpnMenu
// picks up the right screen.
IpcHandler {
    id: ipc

    target: "vpn"

    // Resolve a screen name: explicit arg → primary → first enabled screen → "".
    function _resolveScreen(screen: string): string {
        return screen
            || ShellConfig.primaryScreen
            || (ScreenRegistry.enabledScreens.length > 0 ? ScreenRegistry.enabledScreens[0].name : "");
    }

    // Toggle VPN menu on the primary screen
    function toggleMenu(): void {
        const screen = ipc._resolveScreen("");
        if (screen === "")
            return;
        if (ShellUI.isPopupOpen(screen, "vpn")) {
            ShellUI.closePopup(screen);
        } else {
            ipc.openMenu(screen);
        }
    }

    // Open VPN menu on specified screen (or primary if omitted)
    function openMenu(screen: string): void {
        const targetScreen = ipc._resolveScreen(screen);
        if (targetScreen === "")
            return;
        PopupRegistry.activeScreen = targetScreen;
        const shellScreen = ScreenRegistry.screenByName(targetScreen);
        // 110 = VpnMenu.menuWidth (220) / 2 — centers the menu on the bar
        const anchorX = shellScreen ? Math.max(0, Math.round(shellScreen.width / 2 - 110)) : 0;
        ShellUI.openPopup(targetScreen, "vpn", PopupRegistry.get("vpn"), anchorX);
    }

    // Close VPN menu
    function closeMenu(): void {
        ShellUI.closePopup(ipc._resolveScreen(""));
    }

    // Query VPN menu state
    function isMenuOpen(): bool {
        return ShellUI.isPopupOpen(ipc._resolveScreen(""), "vpn");
    }

    // Query VPN connection state
    function isConnected(): bool {
        return Vpn.connected;
    }

    // Names of currently connected configs
    function connectedNames(): var {
        return Vpn.connectedNames;
    }

    // Disconnect every connected VPN (shell-side only; no password over IPC)
    function disconnectAll(): void {
        Vpn.disconnectAll();
    }
}

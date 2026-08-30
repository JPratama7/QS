pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    property var device: null

    // Internal state properties
    property bool _connected: false
    property string _ssid: ""

    readonly property bool connected: _connected
    readonly property string ssid: _ssid
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled

    // --- Resolved devices (populated in resolveDevice(), re-runs on devices.valuesChanged) ---
    readonly property var wifiDevice: root._wifiDevice
    readonly property var wiredDevices: root._wiredDevices
    // --- Scan state + live model (bound straight to the backend — no copies) ---
    readonly property bool scanning: root.wifiDevice ? root.wifiDevice.scannerEnabled : false
    readonly property var networks: root.wifiDevice ? root.wifiDevice.networks : null
    readonly property bool nmAvailable: Networking.backend !== NetworkBackendType.None
    // --- Re-entrancy guard while an op is in flight ---
    readonly property bool busy: root._pending !== null

    // --- Async outcome signals (UI listens; service also notifies) ---
    signal connectSucceeded(networkName: string)
    signal connectFailed(networkName: string, reasonText: string)

    // --- Internal state ---
    property var _wifiDevice: null
    property var _wiredDevices: ([])
    property var _pending: null   // { net, name, kind: "connect"|"disconnect", ethernet: bool }

    Component.onCompleted: {
        root.resolveDevice();
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() {
            root.resolveDevice();
        }
    }

    Connections {
        target: root.device
        function onConnectedChanged() {
            root.updateNetworkState();
        }
    }

    // Reactive core: watch the in-flight op's target for state changes / failure.
    Connections {
        target: root._pending ? root._pending.net : null
        function onStateChanged() { root._evaluatePending(); }
        function onConnectionFailed(reason) { root._failPending(reason); }
    }

    // Safety net: backend may drop a request silently — unblock the UI rather than wedge it.
    Timer {
        id: pendingSafety
        interval: 30000
        repeat: false
        onTriggered: {
            if (root._pending) {
                root.connectFailed(root._pending.name, "Connection timed out.");
                root._clearPending();
            }
        }
    }

    Process {
        id: notifyProcess
    }

    // Resolve the best available connected device: prefer wifi, fallback to any connected.
    // Also populates _wifiDevice (first Wifi device, any state) and _wiredDevices (all Wired).
    function resolveDevice(): void {
        const devs = Networking.devices;
        if (!devs) {
            return;
        }

        let connectedWifi = null;
        let anyConnected = null;
        let wifiDev = null;
        const wired = [];

        for (const dev of devs.values) {
            if (dev.type === DeviceType.Wifi && !wifiDev) {
                wifiDev = dev;
            }
            if (dev.type === DeviceType.Wired) {
                wired.push(dev);
            }
            if (dev.connected) {
                if (!anyConnected)
                    anyConnected = dev;
                if (dev.type === DeviceType.Wifi && !connectedWifi) {
                    connectedWifi = dev;
                }
            }
        }

        root.device = connectedWifi || anyConnected;
        root._wifiDevice = wifiDev;
        root._wiredDevices = wired;
        root.updateNetworkState();
    }

    // Update connected/ssid from the resolved device
    function updateNetworkState(): void {
        if (!root.device || !root.device.connected) {
            root._connected = false;
            root._ssid = "";
            return;
        }

        root._connected = true;

        if (root.device.type === DeviceType.Wifi) {
            const networks = root.device.networks;
            for (let i = 0; i < networks.count; i++) {
                const net = networks.get(i);
                if (net.connected) {
                    root._ssid = net.name;
                    return;
                }
            }
        }

        root._ssid = root.device.name || "";
    }

    function toggleWifi(): void {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    // --- Scan lifecycle ---
    function startScan(): void {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = true;
    }

    function stopScan(): void {
        if (root.wifiDevice)
            root.wifiDevice.scannerEnabled = false;
    }

    // --- Re-resolution helpers ---
    // The backend recreates WifiNetwork objects on every scan, so caller-held references
    // may be stale. Resolve fresh by name at call time (plan.md §5.3).
    function _resolveNetworkByName(name: string): var {
        if (!root.wifiDevice || !root.wifiDevice.networks)
            return null;
        const nets = root.wifiDevice.networks;
        for (let i = 0; i < nets.count; i++) {
            const n = nets.get(i);
            if (n.name === name)
                return n;
        }
        return null;
    }

    function _resolveWiredByName(name: string): var {
        const wired = root.wiredDevices;
        for (let i = 0; i < wired.length; i++) {
            if (wired[i].name === name)
                return wired[i];
        }
        return null;
    }

    function _setPending(p: var): void {
        root._pending = p;
        pendingSafety.restart();
    }

    function _clearPending(): void {
        root._pending = null;
        pendingSafety.stop();
    }

    function _evaluatePending(): void {
        const p = root._pending;
        if (!p || !p.net)
            return;
        const fresh = p.net;
        if (p.kind === "connect") {
            if (fresh.state === ConnectionState.Connected) {
                root.connectSucceeded(p.name);
                if (p.ethernet) {
                    root.notify("Connected", "You are now connected to " + p.name + ".");
                } else {
                    root.notify("Connection Established",
                        "You are now connected to the Wi-Fi network \"" + p.name + "\".");
                }
                root._clearPending();
            }
        } else if (p.kind === "disconnect") {
            if (!fresh.connected) {
                root.notify("Disconnected",
                    "You have been disconnected from " + p.name + ".");
                root._clearPending();
            }
        }
    }

    function _failPending(reason: int): void {
        const p = root._pending;
        if (!p)
            return;
        const text = root.reasonText(reason).arg(p.name);
        root.connectFailed(p.name, text);
        root.notify("Connection Failed", text);
        root._clearPending();
    }

    // --- Public connect / disconnect / forget ---
    function connectNetwork(net: var): void {
        if (root.busy || !net || net.connected)
            return;
        const fresh = root._resolveNetworkByName(net.name);
        if (!fresh) {
            root.connectFailed(net.name, "Network is no longer in range.");
            return;
        }
        root._setPending({ net: fresh, name: fresh.name, kind: "connect", ethernet: false });
        fresh.connect();
    }

    function connectWithPassword(net: var, password: string): void {
        if (root.busy || !net)
            return;
        const pw = password.trim();
        if (pw === "")
            return;
        const fresh = root._resolveNetworkByName(net.name);
        if (!fresh) {
            root.connectFailed(net.name, "Network is no longer in range.");
            return;
        }
        root._setPending({ net: fresh, name: fresh.name, kind: "connect", ethernet: false });
        fresh.connectWithPsk(pw);
    }

    function disconnectNetwork(net: var): void {
        if (root.busy || !net)
            return;
        const fresh = root._resolveNetworkByName(net.name);
        if (!fresh) {
            root.connectFailed(net.name, "Network is no longer in range.");
            return;
        }
        root._setPending({ net: fresh, name: fresh.name, kind: "disconnect", ethernet: false });
        fresh.disconnect();
    }

    function forgetNetwork(net: var): void {
        if (!net)
            return;
        const fresh = root._resolveNetworkByName(net.name);
        if (!fresh) {
            root.connectFailed(net.name, "Network is no longer in range.");
            return;
        }
        fresh.forget();
        root.notify("Forgotten", "The network " + fresh.name + " has been forgotten.");
    }

    // --- Ethernet (device-level) ---
    function connectEthernet(device: var): void {
        if (root.busy || !device)
            return;
        const fresh = root._resolveWiredByName(device.name);
        if (!fresh || !fresh.network)
            return;
        root._setPending({ net: fresh.network, name: fresh.name, kind: "connect", ethernet: true });
        fresh.network.connect();
    }

    function disconnectDevice(device: var): void {
        if (root.busy || !device)
            return;
        const fresh = root._resolveWiredByName(device.name);
        if (!fresh)
            return;
        root._setPending({ net: fresh, name: fresh.name, kind: "disconnect", ethernet: true });
        fresh.disconnect();
    }

    // --- notify-send subprocess; the shell's own NotificationServer toasts it ---
    function notify(title: string, body: string): void {
        notifyProcess.command = ["notify-send", title, body];
        notifyProcess.startDetached();
    }

    // ConnectionFailReason -> user copy (plan.md §5.4). "%1" is substituted with the
    // network name by the caller (see _failPending); the connectFailed signal already
    // carries the substituted string for the UI.
    function reasonText(reason: int): string {
        switch (reason) {
        case ConnectionFailReason.NoSecrets:
            return "Credentials required for %1.";
        case ConnectionFailReason.WifiAuthTimeout:
            return "Wrong password or connection timed out for %1.";
        case ConnectionFailReason.WifiClientFailed:
        case ConnectionFailReason.WifiClientDisconnected:
        case ConnectionFailReason.WifiNetworkLost:
        case ConnectionFailReason.Unknown:
        default:
            return "Connection failed for %1.";
        }
    }
}

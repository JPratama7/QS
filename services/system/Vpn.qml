pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Backend service for the VPN manager feature
// (docs/necessary-feature/vpn-manager/plan.md §3, §5.1, §5.2, §5.3, §7).
//
// Modeled on TimeZone.qml (set command per call, parse accumulated stdout in
// onRunningChanged when !running) and Cliphist.qml (Process + SplitParser).
// Quickshell.Io.Process has NO `stdin` property — passwords cross into sudo via
// `stdinEnabled: true` + `write(password + "\n")` inside onStarted (verified API,
// plan §3 finding 2). Liveness is ps-based, never `kill -0` (EPERM on root-owned
// openvpn is indistinguishable from dead, plan §3 findings 3–5).
Singleton {
    id: root

    // ------------------------------------------------------------------
    // Public API (plan §5.1)
    // ------------------------------------------------------------------

    readonly property string configDir: Quickshell.cacheDir + "/vpn/configs"
    readonly property string pidDir: Quickshell.cacheDir + "/vpn/pids"

    // Config file names including the .ovpn suffix, e.g. "REY_….ovpn"
    property var configNames: ([])

    // Live in-memory map: config name -> openvpn pid (adopted from pid files by scanProcess)
    property var connectedPids: ({})

    readonly property bool connected: Object.keys(root.connectedPids).length > 0
    readonly property int connectedCount: Object.keys(root.connectedPids).length
    readonly property var connectedNames: Object.keys(root.connectedPids)

    // Emitted when disconnect / disconnectAll / delete cannot use the cached sudo
    // timestamp (`sudo -n` failed). action = {type: "disconnect"|"disconnectAll"|"delete",
    // name, script, arg0, args}; the UI collects the password and calls
    // supplyPassword(action, password) to retry the exact same wrapper.
    signal elevationRequired(action: var)

    // Emitted when a connect attempt fails (sudo auth error) so the UI can return
    // to the password page (plan §5.3 connect flow).
    signal connectFailed()

    function isConnected(name: string): bool {
        return root.connectedPids[name] !== undefined;
    }

    function refresh(): void {
        root._listBuffer = "";
        listProcess.command = ["sh", "-c", root._listScript, "vpn-ls", root.configDir];
        listProcess.running = true;
        root._scan();
    }

    function connect(name: string, password: string): void {
        if (root.isConnected(name)) {
            root._toast(name + " is already connected");
            return;
        }
        // bash parity: connecting implicitly disconnects everything first (one VPN at a time)
        root.disconnectAll();

        root._connectName = name;
        root._connectError = "";
        root._connectPassword = password; // written exactly once in onStarted, then cleared
        connectProcess.stdinEnabled = true;
        connectProcess.command = [
            "sudo", "-S", "sh", "-c", root._connectScript,
            "vpn-connect", root.configDir + "/" + name, root.pidDir
        ];
        connectProcess.running = true;
    }

    function supplyPassword(action: var, password: string): void {
        // Re-runs the exact wrapper that failed the `sudo -n` probe, now feeding
        // the password over stdin. Keeps elevation swappable (plan §7 rule 7):
        // the UI only ever calls connect()/supplyPassword().
        root._pendingAction = action;
        root._elevatePhase = "retry";
        root._elevateError = "";
        root._elevatePassword = password; // written exactly once in onStarted, then cleared
        elevateProcess.stdinEnabled = true;
        elevateProcess.command = ["sudo", "-S", "sh", "-c", action.script, action.arg0].concat(action.args);
        elevateProcess.running = true;
    }

    function disconnect(name: string): void {
        root._startElevated({
            type: "disconnect",
            name: name,
            script: root._disconnectOneScript,
            arg0: "vpn-disconnect-one",
            args: [root.pidDir + "/" + name + ".pid"]
        });
    }

    function disconnectAll(): void {
        root._startElevated({
            type: "disconnectAll",
            name: "",
            script: root._disconnectAllScript,
            arg0: "vpn-disconnect-all",
            args: [root.pidDir]
        });
    }

    function deleteConfig(name: string): void {
        if (root.isConnected(name)) {
            // Kill first; the file cleanup continues when the disconnect succeeds,
            // surviving the possible elevationRequired() detour (type stays "delete").
            root._startElevated({
                type: "delete",
                name: name,
                script: root._disconnectOneScript,
                arg0: "vpn-disconnect-one",
                args: [root.pidDir + "/" + name + ".pid"]
            });
            return;
        }
        root._removeConfigFiles(name);
    }

    function importConfigs(urls: var): void {
        if (!urls || urls.length === 0)
            return;
        const paths = [];
        for (let i = 0; i < urls.length; i++) {
            // FileDialog hands out file:// URLs; cp needs decoded plain paths
            // (plan §3 finding 6). Pass each path as its own argv element.
            let path = String(urls[i]);
            if (path.indexOf("file://") === 0) {
                try {
                    path = decodeURIComponent(path.substring(7));
                } catch (e) {
                    path = path.substring(7); // keep raw path on malformed escapes
                }
            }
            if (path.length < 5 || path.lastIndexOf(".ovpn") !== path.length - 5) {
                root._toast("Skipped " + path.substring(path.lastIndexOf("/") + 1) + " - only .ovpn files are supported");
                continue;
            }
            paths.push(path);
        }
        if (paths.length === 0)
            return;
        root._fileMode = "import";
        root._importCount = paths.length;
        fileProcess.command = ["sh", "-c", root._importScript, "vpn-import", root.configDir].concat(paths);
        fileProcess.running = true;
    }

    // ------------------------------------------------------------------
    // Shell wrappers — explicit argv only, never interpolate shell from QML
    // (plan §5.2). Verbatim from the plan.
    // ------------------------------------------------------------------

    readonly property string _listScript: "ls -1 \"$1\"/*.ovpn 2>/dev/null";

    // Liveness via ps (reads /proc, ownership-independent); stale pid files are
    // deleted here and the comm=openvpn check guards against pid reuse.
    readonly property string _scanScript: "for f in \"$1\"/*.pid; do [ -e \"$f\" ] || continue; name=$(basename \"$f\" .pid); pid=$(cat \"$f\"); if [ -n \"$pid\" ] && ps -p \"$pid\" -o comm= 2>/dev/null | grep -qx openvpn; then echo \"$name $pid\"; else rm -f \"$f\"; fi; done";

    // </dev/null gives openvpn an immediate EOF on stdin (auth-user-pass parity —
    // an open pipe would hang at the prompt, plan §3 finding 8); the cd fixes the
    // bash script's latent relative-path bug. Pid file naming MUST stay
    // <config-filename>.pid (bash parity).
    readonly property string _connectScript: "cd \"$(dirname \"$1\")\" && mkdir -p \"$2\" && nohup openvpn --config \"$1\" </dev/null >/dev/null 2>&1 & echo $! > \"$2/$(basename \"$1\").pid\"";

    readonly property string _disconnectAllScript: "for f in \"$1\"/*.pid; do [ -e \"$f\" ] || continue; pid=$(cat \"$f\"); [ -n \"$pid\" ] && { kill \"$pid\" 2>/dev/null; sleep 1; ps -p \"$pid\" >/dev/null 2>&1 && kill -9 \"$pid\" 2>/dev/null; }; rm -f \"$f\"; done";

    readonly property string _disconnectOneScript: "f=\"$1\"; [ -e \"$f\" ] || exit 0; pid=$(cat \"$f\"); [ -n \"$pid\" ] && { kill \"$pid\" 2>/dev/null; sleep 1; ps -p \"$pid\" >/dev/null 2>&1 && kill -9 \"$pid\" 2>/dev/null; }; rm -f \"$f\"; exit 0";

    readonly property string _importScript: "d=\"$1\"; shift; for s in \"$@\"; do cp \"$s\" \"$d/\" 2>/dev/null; done";

    readonly property string _cleanupScript: "rm -f \"$1\" \"$2\"";

    // One-time adoption of the bash menu's data (~/.cache/rofivpnmenu). Self-guarding:
    // copies only when the new config dir has no .ovpn yet AND the old dirs have
    // files; originals are kept (cp -n, never mv).
    readonly property string _migrateScript: "sc=\"$1\"; sp=\"$2\"; dc=\"$3\"; dp=\"$4\"; [ -d \"$sc\" ] || exit 0; [ -n \"$(ls -1 \"$dc\"/*.ovpn 2>/dev/null)\" ] && exit 0; [ -n \"$(ls -1 \"$sc\"/*.ovpn 2>/dev/null)\" ] && cp -n \"$sc\"/*.ovpn \"$dc/\" 2>/dev/null; [ -d \"$sp\" ] && [ -n \"$(ls -1 \"$sp\"/*.pid 2>/dev/null)\" ] && cp -n \"$sp\"/*.pid \"$dp/\" 2>/dev/null; exit 0";

    // ------------------------------------------------------------------
    // Internal state
    // ------------------------------------------------------------------

    property string _listBuffer: ""
    property string _scanBuffer: ""
    property string _fileBuffer: ""
    property string _fileMode: "none"       // what fileProcess should do when it finishes
    property string _connectName: ""        // config currently connecting ("" = aborted)
    property string _connectError: ""       // captured sudo stderr; never logged (plan §7 rule 5)
    property string _connectPassword: ""    // in-memory only; cleared right after the single write()
    property int _connectExitCode: 0        // captured from the exited() signal (no exitCode property)
    property string _elevateError: ""
    property string _elevatePassword: ""    // in-memory only; cleared right after the single write()
    property int _elevateExitCode: 0        // captured from the exited() signal (no exitCode property)
    property string _elevatePhase: "probe"  // "probe" = sudo -n fast path, "retry" = sudo -S
    property var _pendingAction: null       // elevate action in flight (null = ignore completion)
    property string _pendingAdoptName: ""   // config awaiting pid-file adoption after connect
    property string _pendingDeleteName: ""  // config awaiting file cleanup after delete
    property int _importCount: 0

    // ------------------------------------------------------------------
    // Timers
    // ------------------------------------------------------------------

    // Wedged-sudo guard for every elevated process (plan §7 rule 6): clearing the
    // pending marker BEFORE stopping makes the completion handler stay silent.
    Timer {
        id: connectWatchdog
        interval: 30000
        onTriggered: {
            root._connectName = "";
            root._connectPassword = "";
            root._toast("Connection timed out");
            if (connectProcess.running)
                connectProcess.running = false;
        }
    }

    Timer {
        id: elevateWatchdog
        interval: 30000
        onTriggered: {
            root._pendingAction = null;
            root._elevatePassword = "";
            root._elevateError = "";
            root._toast("Operation timed out");
            if (elevateProcess.running)
                elevateProcess.running = false;
        }
    }

    // Death detection for detached openvpn processes: they are not our children,
    // so no Process.exited() can fire — poll the ps-based scan every 5 s instead
    // (plan §3 finding 5). The binding starts/stops polling as the map fills/empties.
    Timer {
        id: scanTimer
        interval: 5000
        repeat: true
        running: root.connected
        onTriggered: root._scan()
    }

    // ------------------------------------------------------------------
    // Processes (one per responsibility, TimeZone style)
    // ------------------------------------------------------------------

    Process {
        id: ensureDirsProcess
        command: ["mkdir", "-p", root.configDir, root.pidDir]

        stderr: SplitParser {
            onRead: data => console.warn("Vpn mkdir error:", data)
        }

        onRunningChanged: {
            if (!running)
                root._migrate(); // sequential startup chain step 2
        }
    }

    Process {
        id: migrateProcess

        onRunningChanged: {
            if (!running)
                root.refresh(); // chain step 3: relist + initial scan (adopts live pids)
        }
    }

    Process {
        id: listProcess

        stdout: SplitParser {
            onRead: data => {
                root._listBuffer += data + "\n";
            }
        }

        stderr: SplitParser {
            onRead: data => console.warn("Vpn list error:", data)
        }

        onRunningChanged: {
            if (!running) {
                // ls globbed dir/*.ovpn, so strip every path down to its file name
                root.configNames = root._listBuffer.split("\n")
                    .filter(l => l.trim() !== "")
                    .map(l => l.substring(l.lastIndexOf("/") + 1));
                root._listBuffer = "";
            }
        }
    }

    Process {
        id: scanProcess

        stdout: SplitParser {
            onRead: data => {
                root._scanBuffer += data + "\n";
            }
        }

        onRunningChanged: {
            if (!running) {
                // scan lines are "<name> <pid>"; split on the LAST space so config
                // names containing spaces still parse (pids never contain spaces)
                const live = {};
                const lines = root._scanBuffer.split("\n").filter(l => l.trim() !== "");
                for (let i = 0; i < lines.length; i++) {
                    const sep = lines[i].lastIndexOf(" ");
                    if (sep <= 0)
                        continue;
                    const pid = parseInt(lines[i].substring(sep + 1));
                    if (!isNaN(pid) && pid > 0)
                        live[lines[i].substring(0, sep)] = pid;
                }
                root.connectedPids = live; // reassign so dependents re-evaluate
                root._scanBuffer = "";
            }
        }
    }

    Process {
        id: connectProcess
        stdinEnabled: true

        // stdout intentionally unmonitored: nothing there but silence, and keeping
        // handlers away from the password path avoids accidental leakage (plan §7 rule 5)
        stderr: SplitParser {
            onRead: data => {
                root._connectError += data;
            }
        }

        onStarted: {
            // The one and only password crossing — via stdin, never argv/env/sh -c.
            connectProcess.write(root._connectPassword + "\n");
            root._connectPassword = "";
            connectWatchdog.restart();
        }

        onExited: (exitCode, exitStatus) => {
            root._connectExitCode = exitCode;
        }

        onRunningChanged: {
            if (!running) {
                connectWatchdog.stop();
                root._finishConnect();
            }
        }
    }

    Process {
        id: elevateProcess

        stderr: SplitParser {
            onRead: data => {
                root._elevateError += data;
            }
        }

        onStarted: {
            if (root._elevatePhase === "retry") {
                elevateProcess.write(root._elevatePassword + "\n");
                root._elevatePassword = "";
            }
            elevateWatchdog.restart();
        }

        onExited: (exitCode, exitStatus) => {
            root._elevateExitCode = exitCode;
        }

        onRunningChanged: {
            if (running)
                return;
            elevateWatchdog.stop();
            elevateProcess.stdinEnabled = false;
            const action = root._pendingAction;
            root._pendingAction = null;
            const err = root._elevateError;
            root._elevateError = "";
            if (!action)
                return; // watchdog abort or stray completion

            if (root._elevateExitCode === 0 && err === "") {
                root._elevateSuccess(action);
            } else if (root._elevatePhase === "probe") {
                // sudo timestamp cache missed → UI collects the password (plan §5.2)
                root.elevationRequired(action);
            } else {
                root._elevatePhase = "probe";
                root._toast("sudo authentication failed - check your password");
            }
        }
    }

    // Shared worker for unprivileged file ops: import (cp), pid-file rm, config
    // cleanup rm, pid-file cat. Ops are user-driven and effectively sequential;
    // _fileMode routes each completion.
    Process {
        id: fileProcess

        stdout: SplitParser {
            onRead: data => {
                root._fileBuffer += data;
            }
        }

        stderr: SplitParser {
            onRead: data => console.warn("Vpn file op error:", data)
        }

        onRunningChanged: {
            if (running)
                return;
            const mode = root._fileMode;
            root._fileMode = "none";
            if (mode === "adopt") {
                const pid = parseInt(root._fileBuffer.trim());
                const name = root._pendingAdoptName;
                root._fileBuffer = "";
                root._pendingAdoptName = "";
                if (name !== "" && !isNaN(pid) && pid > 0) {
                    const next = Object.assign({}, root.connectedPids);
                    next[name] = pid;
                    root.connectedPids = next;
                    root._toast("Connecting to " + name + " initiated");
                }
                root.refresh();
            } else if (mode === "rm-pid") {
                root.refresh();
            } else if (mode === "delete-cleanup") {
                const deleted = root._pendingDeleteName;
                root._pendingDeleteName = "";
                root._toast("Deleted " + deleted);
                root.refresh();
            } else if (mode === "import") {
                root._toast("Imported " + root._importCount + " config(s)");
                root._importCount = 0;
                root.refresh();
            }
        }
    }

    Process {
        id: notifyProcess
    }

    // ------------------------------------------------------------------
    // Internals
    // ------------------------------------------------------------------

    Component.onCompleted: {
        ensureDirsProcess.running = true; // startup chain step 1
    }

    function _scan(): void {
        root._scanBuffer = "";
        scanProcess.command = ["sh", "-c", root._scanScript, "vpn-scan", root.pidDir];
        scanProcess.running = true;
    }

    function _migrate(): void {
        migrateProcess.command = [
            "sh", "-c", root._migrateScript, "vpn-migrate",
            Quickshell.cacheDir + "/rofivpnmenu/vpns",
            Quickshell.cacheDir + "/rofivpnmenu/pids",
            root.configDir,
            root.pidDir
        ];
        migrateProcess.running = true;
    }

    // sudo -n fast path: uses sudo's timestamp cache, usually fresh right after a
    // connect; any non-zero exit escalates to the UI password page (plan §5.2 role 2).
    function _startElevated(action: var): void {
        root._pendingAction = action;
        root._elevatePhase = "probe";
        root._elevateError = "";
        elevateProcess.command = ["sudo", "-n", "sh", "-c", action.script, action.arg0].concat(action.args);
        elevateProcess.running = true;
    }

    function _elevateSuccess(action: var): void {
        if (action.type === "disconnect") {
            root._dropPid(action.name);
            root._removePidFile(action.name); // unprivileged rm: user owns the cache dir
            root._toast("Disconnected from " + action.name);
        } else if (action.type === "disconnectAll") {
            root.connectedPids = ({}); // wrapper already removed every pid file
            root._toast("Disconnected from all VPNs");
            root.refresh();
        } else if (action.type === "delete") {
            root._dropPid(action.name);
            root._removeConfigFiles(action.name); // continues the deleteConfig() pipeline
        }
    }

    // Reassign a fresh object instead of deleting in place so that bindings on
    // connectedPids (connected/count/names) re-evaluate.
    function _dropPid(name: string): void {
        const next = Object.assign({}, root.connectedPids);
        delete next[name];
        root.connectedPids = next;
    }

    function _finishConnect(): void {
        const name = root._connectName;
        root._connectName = "";
        root._connectPassword = "";
        const err = root._connectError;
        root._connectError = "";
        if (name === "")
            return; // watchdog abort — already toasted
        if (root._connectExitCode !== 0 || err !== "") {
            root.connectFailed(); // UI returns to the password page (plan §5.3)
            root._toast("Connection failed - sudo authentication failed - check your password");
            return;
        }
        // Adopt the wrapper-written pid file via unprivileged cat
        root._fileMode = "adopt";
        root._pendingAdoptName = name;
        root._fileBuffer = "";
        fileProcess.command = ["cat", root.pidDir + "/" + name + ".pid"];
        fileProcess.running = true;
    }

    function _removePidFile(name: string): void {
        root._fileMode = "rm-pid";
        fileProcess.command = ["rm", "-f", root.pidDir + "/" + name + ".pid"];
        fileProcess.running = true;
    }

    function _removeConfigFiles(name: string): void {
        root._pendingDeleteName = name;
        root._fileMode = "delete-cleanup";
        fileProcess.command = ["sh", "-c", root._cleanupScript, "vpn-cleanup",
            root.configDir + "/" + name, root.pidDir + "/" + name + ".pid"];
        fileProcess.running = true;
    }

    function _toast(message: string): void {
        // Rendered by the in-shell NotificationServer daemon (plan §3) — no new infra
        notifyProcess.command = ["notify-send", "OpenVPN", message];
        notifyProcess.startDetached();
    }
}

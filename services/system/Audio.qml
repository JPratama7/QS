pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property var sink: null

    // Bind the sink node to ensure audio properties are available
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // Internal state properties
    property real _volume: 0
    property bool _muted: false

    readonly property real volume: _volume
    readonly property bool muted: _muted

    Connections {
        target: Pipewire
        function onReadyChanged() {
            if (Pipewire.ready) {
                root.resolveSink();
            }
        }
    }

    Connections {
        target: root
        function onSinkChanged() {
            if (root.sink) {
                root.updateAudioState();
            }
        }
    }

    Connections {
        target: root.sink
        enabled: !!root.sink
        function onReadyChanged() {
            if (root.sink.ready) {
                root.updateAudioState();
            }
        }
    }

    Connections {
        target: root.sink?.audio ?? null
        function onVolumeChanged() {
            root._volume = root.sink.audio.volume;
        }
        function onMutedChanged() {
            root._muted = root.sink.audio.muted;
        }
    }

    // Resolve the best available sink: prefer default, fallback to first working sink
    function resolveSink(): void {
        if (!Pipewire.ready) {
            return;
        }

        const defaultSink = Pipewire.defaultAudioSink;

        // Use default sink if it has audio interface
        if (defaultSink && defaultSink.audio) {
            root.sink = defaultSink;
            return;
        }

        // Fallback: find first sink with audio interface from nodes
        if (Pipewire.nodes) {
            for (var i = 0; i < Pipewire.nodes.values.length; i++) {
                const node = Pipewire.nodes.values[i];
                if (node && node.isSink && node.audio) {
                    root.sink = node;
                    return;
                }
            }
        }

        // Last resort: use default sink even without audio (may become available later)
        if (defaultSink) {
            root.sink = defaultSink;
        }
    }

    // Update volume/muted from sink audio (only when ready)
    function updateAudioState(): void {
        if (!root.sink || !root.sink.ready || !root.sink.audio) {
            return;
        }

        root._volume = root.sink.audio.volume;
        root._muted = root.sink.audio.muted;
    }

    function setVolume(value: real): void {
        if (sink && sink.audio) {
            sink.audio.volume = value;
        }
    }

    function toggleMute(): void {
        if (sink && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }
}

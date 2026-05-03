pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Track the default audio sink so its audio properties are live
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // Directly bind to the default sink's audio properties
    readonly property real volume: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
        ? Pipewire.defaultAudioSink.audio.volume
        : 0

    readonly property bool muted: (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio)
        ? Pipewire.defaultAudioSink.audio.muted
        : false

    readonly property string sinkDescription: Pipewire.defaultAudioSink
        ? (Pipewire.defaultAudioSink.description || Pipewire.defaultAudioSink.nickname || Pipewire.defaultAudioSink.name || "")
        : ""

    // Per-channel volume info as a pre-formatted string for display (e.g. "FL: 75%  FR: 75%")
    readonly property string channelVolumeText: {
        if (!Pipewire.defaultAudioSink || !Pipewire.defaultAudioSink.audio)
            return "";
        const audio = Pipewire.defaultAudioSink.audio;
        const chs = audio.channels || [];
        const vols = audio.volumes || [];
        if (chs.length === 0)
            return "";
        const parts = [];
        for (let i = 0; i < chs.length; i++) {
            const name = PwAudioChannel.toString(chs[i]);
            const pct = Math.round((vols[i] ?? 0) * 100);
            parts.push(name + ": " + pct + "%");
        }
        return parts.join("  ");
    }

    function setVolume(value: real): void {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.volume = value;
        }
    }

    function toggleMute(): void {
        if (Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }
}

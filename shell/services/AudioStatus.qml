import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    /*
     * Current default output.
     */

    property var sink: Pipewire.defaultAudioSink

    property bool available:
        sink !== null
        && sink.audio !== null

    property int volume:
        available
            ? Math.round(sink.audio.volume * 100)
            : 0

    property bool muted:
        available
            ? sink.audio.muted
            : false


    /*
     * PipeWire nodes have to be bound before
     * volume/mute can be read or changed.
     */

    PwObjectTracker {
        objects: [
            root.sink
        ]
    }


    /*
     * Volume control.
     */

    function setVolume(value) {
        if (!available)
            return

        const clamped =
            Math.max(
                0,
                Math.min(1, value)
            )

        sink.audio.volume = clamped
    }

    function increase() {
        if (!available)
            return

        setVolume(
            sink.audio.volume + 0.05
        )
    }

    function decrease() {
        if (!available)
            return

        setVolume(
            sink.audio.volume - 0.05
        )
    }

    function toggleMute() {
        if (!available)
            return

        sink.audio.muted =
            !sink.audio.muted
    }
}

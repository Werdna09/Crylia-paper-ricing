import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Scope {
    id: root

    /*
     * Prefer the player which is currently playing.
     * If nothing is playing, keep the first available
     * MPRIS player.
     */

    readonly property var player: {
        const players = Mpris.players.values

        for (const candidate of players) {
            if (candidate.isPlaying) {
                return candidate
            }
        }

        return players.length > 0
            ? players[0]
            : null
    }


    readonly property bool available:
        player !== null

    readonly property bool playing:
        available
        && player.isPlaying

    readonly property string artist:
        available
            ? player.trackArtist
            : ""

    readonly property string title:
        available
            ? player.trackTitle
            : ""

    readonly property string identity:
        available
            ? player.identity
            : ""


    /*
     * Compact text for the top bar.
     */

    readonly property string displayText: {
        if (!available) {
            return "No media"
        }

        if (artist.length > 0 && title.length > 0) {
            return artist + " · " + title
        }

        if (title.length > 0) {
            return title
        }

        if (artist.length > 0) {
            return artist
        }

        if (identity.length > 0) {
            return identity
        }

        return "Media"
    }


    /*
     * Controls
     */

    function togglePlaying() {
        if (
            available
            && player.canTogglePlaying
        ) {
            player.togglePlaying()
        }
    }

    function next() {
        if (
            available
            && player.canGoNext
        ) {
            player.next()
        }
    }

    function previous() {
        if (
            available
            && player.canGoPrevious
        ) {
            player.previous()
        }
    }
}

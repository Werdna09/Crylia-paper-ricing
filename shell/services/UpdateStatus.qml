import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property int repoCount: 0
    property int aurCount: 0

    readonly property int totalCount:
        repoCount + aurCount

    readonly property bool checking:
        repoProcess.running
        || aurProcess.running


    /*
     * Count non-empty lines.
     */

    function countLines(text) {
        const trimmed = text.trim()

        if (trimmed.length === 0) {
            return 0
        }

        return trimmed
            .split("\n")
            .filter(line => line.trim().length > 0)
            .length
    }


    /*
     * Refresh update counts.
     */

    function refresh() {
        if (!repoProcess.running) {
            repoProcess.running = true
        }

        if (!aurProcess.running) {
            aurProcess.running = true
        }
    }


    /*
     * Official CachyOS / Arch repositories.
     */

    Process {
        id: repoProcess

        command: [
            "checkupdates"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.repoCount =
                    root.countLines(text)
            }
        }
    }


    /*
     * AUR updates.
     */

    Process {
        id: aurProcess

        command: [
            "paru",
            "-Qua"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.aurCount =
                    root.countLines(text)
            }
        }
    }


    /*
     * Check every 30 minutes.
     */

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true

        onTriggered: {
            root.refresh()
        }
    }


    /*
     * Initial check.
     */

    Component.onCompleted: {
        refresh()
    }
}

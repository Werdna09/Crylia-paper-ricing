import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property int current: 1


    /*
     * Read current KDE workspace
     */

    function refresh() {
        if (!currentDesktopQuery.running) {
            currentDesktopQuery.running = true
        }
    }


    /*
     * Switch KDE workspace
     */

    function switchTo(desktop) {
        if (desktop < 1 || desktop > 4) {
            return
        }

        // Immediate visual response.
        root.current = desktop

        Quickshell.execDetached([
            "qdbus6",
            "org.kde.KWin",
            "/KWin",
            "org.kde.KWin.setCurrentDesktop",
            String(desktop)
        ])
    }


    /*
     * Ask KWin which workspace is active.
     */

    Process {
        id: currentDesktopQuery

        command: [
            "qdbus6",
            "org.kde.KWin",
            "/KWin",
            "org.kde.KWin.currentDesktop"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const desktop = parseInt(text.trim())

                if (
                    !isNaN(desktop)
                    && desktop >= 1
                    && desktop <= 4
                ) {
                    root.current = desktop
                }
            }
        }
    }


    /*
     * Watch KWin for workspace changes.
     */

    Process {
        id: workspaceMonitor

        running: true

        command: [
            "dbus-monitor",
            "--session",
            "type='signal',path='/VirtualDesktopManager',interface='org.kde.KWin.VirtualDesktopManager',member='currentChanged'"
        ]

        stdout: SplitParser {
            onRead: line => {
                if (
                    line.indexOf(
                        "member=currentChanged"
                    ) !== -1
                ) {
                    root.refresh()
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                running = true
            }
        }
    }


    /*
     * Get initial workspace when Crylia starts.
     */

    Component.onCompleted: {
        refresh()
    }
}

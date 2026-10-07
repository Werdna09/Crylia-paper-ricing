import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root


    /*
     * ============================================================
     * Keyboard layout
     * ============================================================
     */

    property int currentIndex: 0

    readonly property var labels: [
        "CZ",
        "EN"
    ]

    readonly property string label:
        currentIndex >= 0
        && currentIndex < labels.length
            ? labels[currentIndex]
            : "??"


    /*
     * ============================================================
     * Lock state
     * ============================================================
     */

    property string capsPath: ""
    property string numPath: ""

    readonly property bool capsLock:
        capsPath !== ""
        && capsFile.loaded
        && capsFile.text().trim() === "1"

    readonly property bool numLock:
        numPath !== ""
        && numFile.loaded
        && numFile.text().trim() === "1"


    /*
     * Short lock indicator:
     *
     * ""   -> nothing
     * C    -> CapsLock
     * N    -> NumLock
     * CN   -> both
     */

    readonly property string lockSuffix:
        (capsLock ? "C" : "")
        + (numLock ? "N" : "")

    readonly property string displayLabel:
        lockSuffix.length > 0
            ? label + " " + lockSuffix
            : label


    /*
     * ============================================================
     * Layout control
     * ============================================================
     */

    function refreshLayout() {
        if (!currentLayoutProcess.running) {
            currentLayoutProcess.running = true
        }
    }

    function nextLayout() {
        Quickshell.execDetached([
            "qdbus6",
            "org.kde.keyboard",
            "/Layouts",
            "org.kde.KeyboardLayouts.switchToNextLayout"
        ])
    }


    /*
     * Read active KDE layout.
     */

    Process {
        id: currentLayoutProcess

        command: [
            "qdbus6",
            "org.kde.keyboard",
            "/Layouts",
            "org.kde.KeyboardLayouts.getLayout"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const index = parseInt(text.trim())

                if (!isNaN(index)) {
                    root.currentIndex = index
                }
            }
        }
    }


    /*
     * Watch KDE for layout changes.
     */

    Process {
        id: layoutMonitor

        running: true

        command: [
            "dbus-monitor",
            "--session",
            "type='signal',path='/Layouts',interface='org.kde.KeyboardLayouts',member='layoutChanged'"
        ]

        stdout: SplitParser {
            onRead: line => {
                if (
                    line.indexOf(
                        "member=layoutChanged"
                    ) !== -1
                ) {
                    root.refreshLayout()
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
     * ============================================================
     * Discover CapsLock LED
     * ============================================================
     */

    Process {
        id: findCapsProcess

        running: true

        command: [
            "find",
            "/sys/class/leds",
            "-maxdepth",
            "1",
            "-name",
            "*::capslock",
            "-print",
            "-quit"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.capsPath = text.trim()
            }
        }
    }


    /*
     * Discover NumLock LED
     */

    Process {
        id: findNumProcess

        running: true

        command: [
            "find",
            "/sys/class/leds",
            "-maxdepth",
            "1",
            "-name",
            "*::numlock",
            "-print",
            "-quit"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.numPath = text.trim()
            }
        }
    }


    /*
     * ============================================================
     * Read LEDs
     * ============================================================
     */

    FileView {
        id: capsFile

        path: root.capsPath !== ""
            ? "file://" + root.capsPath + "/brightness"
            : ""

        printErrors: false
    }

    FileView {
        id: numFile

        path: root.numPath !== ""
            ? "file://" + root.numPath + "/brightness"
            : ""

        printErrors: false
    }


    /*
     * sysfs is tiny, so re-reading these two one-byte files
     * is essentially free.
     *
     * We do this instead of hardcoding input4/input5.
     */

    Timer {
        interval: 300
        running: true
        repeat: true

        onTriggered: {
            if (root.capsPath !== "") {
                capsFile.reload()
            }

            if (root.numPath !== "") {
                numFile.reload()
            }
        }
    }


    /*
     * ============================================================
     * Initial state
     * ============================================================
     */

    Component.onCompleted: {
        refreshLayout()
    }
}

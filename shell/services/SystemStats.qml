import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    /*
     * Public values for the bar
     */

    property int cpuUsage: 0
    property int cpuTemp: 0


    /*
     * Previous /proc/stat values
     * needed to calculate CPU usage.
     */

    property double previousTotal: 0
    property double previousIdle: 0


    /*
     * CPU usage
     */

    Process {
        id: cpuStatProcess

        running: true

        command: [
            "head",
            "-n",
            "1",
            "/proc/stat"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)

                if (parts.length < 9 || parts[0] !== "cpu") {
                    return
                }

                const user = Number(parts[1])
                const nice = Number(parts[2])
                const system = Number(parts[3])
                const idle = Number(parts[4])
                const iowait = Number(parts[5])
                const irq = Number(parts[6])
                const softirq = Number(parts[7])
                const steal = Number(parts[8])

                const idleTotal =
                    idle + iowait

                const total =
                    user
                    + nice
                    + system
                    + idle
                    + iowait
                    + irq
                    + softirq
                    + steal

                if (root.previousTotal > 0) {
                    const totalDelta =
                        total - root.previousTotal

                    const idleDelta =
                        idleTotal - root.previousIdle

                    if (totalDelta > 0) {
                        root.cpuUsage = Math.round(
                            100 *
                            (totalDelta - idleDelta)
                            / totalDelta
                        )
                    }
                }

                root.previousTotal = total
                root.previousIdle = idleTotal
            }
        }
    }


    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!cpuStatProcess.running) {
                cpuStatProcess.running = true
            }
        }
    }


    /*
     * CPU temperature
     *
     * thermal_zone6 = x86_pkg_temp
     * on this machine.
     */

    Process {
        id: cpuTempProcess

        running: true

        command: [
            "cat",
            "/sys/class/thermal/thermal_zone6/temp"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const rawTemperature =
                    parseInt(text.trim())

                if (!isNaN(rawTemperature)) {
                    root.cpuTemp = Math.round(
                        rawTemperature / 1000
                    )
                }
            }
        }
    }


    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            if (!cpuTempProcess.running) {
                cpuTempProcess.running = true
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Scope {
    id: root


    /*
     * ============================================================
     * WIFI
     * ============================================================
     */

    readonly property var wifiDevice: {
        const devices = Networking.devices.values

        for (const device of devices) {
            if (device.type === DeviceType.Wifi) {
                return device
            }
        }

        return null
    }


    readonly property var wifiNetworks:
        wifiDevice !== null
            ? wifiDevice.networks
            : null


    readonly property var currentWifi: {
        if (wifiDevice === null) {
            return null
        }

        const networks = wifiDevice.networks.values

        for (const wifi of networks) {
            if (wifi.connected) {
                return wifi
            }
        }

        return null
    }


    readonly property bool wifiEnabled:
        Networking.wifiEnabled


    readonly property bool wifiConnected:
        currentWifi !== null


    readonly property string wifiName:
        currentWifi !== null
            ? currentWifi.name
            : ""


    function toggleWifi() {
        if (!Networking.wifiHardwareEnabled) {
            return
        }

        Networking.wifiEnabled =
            !Networking.wifiEnabled
    }


    function enableScanner() {
        if (wifiDevice !== null) {
            wifiDevice.scannerEnabled = true
        }
    }


    /*
     * Keep the NetworkManager scanner available for
     * our shell. This gives us a live WifiNetwork model.
     */

    onWifiDeviceChanged: {
        enableScanner()
    }


    /*
     * ============================================================
     * BLUETOOTH
     *
     * For now we keep our existing bluetoothctl backend.
     * We will replace this with Quickshell.Bluetooth when
     * we build the Bluetooth popup.
     * ============================================================
     */

    property bool bluetoothPowered: false
    property int bluetoothConnectedCount: 0


    Process {
        id: bluetoothStateProcess

        running: true

        command: [
            "bluetoothctl",
            "show"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.bluetoothPowered =
                    text.indexOf(
                        "Powered: yes"
                    ) !== -1
            }
        }
    }


    Process {
        id: bluetoothDevicesProcess

        running: true

        command: [
            "bluetoothctl",
            "devices",
            "Connected"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                if (output.length === 0) {
                    root.bluetoothConnectedCount = 0
                    return
                }

                const devices =
                    output
                        .split("\n")
                        .filter(
                            line =>
                                line
                                    .trim()
                                    .startsWith("Device ")
                        )

                root.bluetoothConnectedCount =
                    devices.length
            }
        }
    }


    function refreshBluetooth() {
        if (!bluetoothStateProcess.running) {
            bluetoothStateProcess.running = true
        }

        if (!bluetoothDevicesProcess.running) {
            bluetoothDevicesProcess.running = true
        }
    }


    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            root.refreshBluetooth()
        }
    }


    /*
     * ============================================================
     * INITIAL STATE
     * ============================================================
     */

    Component.onCompleted: {
        enableScanner()
        refreshBluetooth()
    }
}

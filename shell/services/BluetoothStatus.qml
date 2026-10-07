import QtQuick
import Quickshell
import Quickshell.Bluetooth

Scope {
    id: root

    readonly property var adapter:
        Bluetooth.defaultAdapter

    readonly property bool available:
        adapter !== null

    readonly property bool enabled:
        available
        && adapter.enabled

    readonly property bool discovering:
        available
        && adapter.discovering

    readonly property var devices:
        available
            ? adapter.devices
            : null

    readonly property int connectedCount: {
        if (!available) {
            return 0
        }

        let count = 0
        const values = adapter.devices.values

        for (const device of values) {
            if (device.connected) {
                count++
            }
        }

        return count
    }


    function toggleEnabled() {
        if (!available) {
            return
        }

        adapter.enabled =
            !adapter.enabled
    }


    function startDiscovery() {
        if (
            available
            && enabled
        ) {
            adapter.discovering = true
        }
    }


    function stopDiscovery() {
        if (!available) {
            return
        }

        adapter.discovering = false
    }


    function toggleDiscovery() {
        if (
            !available
            || !enabled
        ) {
            return
        }

        adapter.discovering =
            !adapter.discovering
    }
}

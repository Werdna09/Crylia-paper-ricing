import QtQuick
import Quickshell
import Quickshell.Services.UPower

Scope {
    id: root

    readonly property var battery:
        UPower.displayDevice

    readonly property bool available:
        battery !== null
        && battery.ready

    /*
     * Quickshell returns battery percentage
     * as a 0.0–1.0 value.
     */

    readonly property int percentage:
        available
            ? Math.round(battery.percentage * 100)
            : 0

    readonly property bool charging:
        available
        && (
            battery.state === UPowerDeviceState.Charging
            || battery.state === UPowerDeviceState.PendingCharge
        )

    readonly property bool fullyCharged:
        available
        && battery.state === UPowerDeviceState.FullyCharged

    readonly property bool discharging:
        available
        && battery.state === UPowerDeviceState.Discharging

    readonly property real timeToEmpty:
        available
            ? battery.timeToEmpty
            : 0

    readonly property real timeToFull:
        available
            ? battery.timeToFull
            : 0


    /*
     * Battery health is normalized the same way.
     */

    readonly property bool healthAvailable:
        available
        && battery.healthSupported

    readonly property int health:
        healthAvailable
            ? Math.round(
                battery.healthPercentage * 100
            )
            : 0
}

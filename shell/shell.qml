//@ pragma ShellId crylia-paper

import QtQuick
import Quickshell

import qs.services
import qs.popups


ShellRoot {
    /*
     * ============================================================
     * SERVICES
     * ============================================================
     */

    KWinWorkspaces {
        id: workspaces
    }

    SystemStats {
        id: stats
    }

    NetworkStatus {
        id: network
    }

    BluetoothStatus {
        id: bluetooth
    }

    AudioStatus {
        id: audio
    }

    KeyboardStatus {
        id: keyboard
    }

    UpdateStatus {
        id: updates
    }

    BatteryStatus {
        id: battery
    }

    MediaStatus {
        id: media
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }


    /*
     * ============================================================
     * PANEL
     * ============================================================
     */

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow

            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 50
            exclusiveZone: 50

            color: "transparent"


            /*
             * ====================================================
             * POPUP HELPERS
             * ====================================================
             */

            function closeAllPopups() {
                audioPopup.visible = false
                wifiPopup.visible = false
                bluetoothPopup.visible = false
                batteryPopup.visible = false
                updatesPopup.visible = false
                mediaPopup.visible = false
                powerPopup.visible = false
                calendarPopup.visible = false
            }


            function togglePopup(targetPopup) {
                const shouldOpen =
                    !targetPopup.visible

                closeAllPopups()

                targetPopup.visible =
                    shouldOpen
            }


            /*
             * ====================================================
             * MAIN PANEL SURFACE
             * ====================================================
             */

            Rectangle {
                id: panel

                anchors.fill: parent

                radius: 0
                color: "#2b2d3a"

                border.width: 0


                /*
                 * =================================================
                 * LEFT — WORKSPACES
                 * =================================================
                 */

                Rectangle {
                    id: workspaceIsland

                    anchors {
                        left: parent.left
                        leftMargin: 6
                        verticalCenter: parent.verticalCenter
                    }

                    width: workspaceRow.width + 10
                    height: 40

                    radius: 6
                    color: "#333648"

                    border.width: 1
                    border.color: "#393e53"


                    Row {
                        id: workspaceRow

                        anchors.centerIn: parent

                        spacing: 4


                        Repeater {
                            model: 4

                            Rectangle {
                                id: workspaceButton

                                required property int index

                                property int desktopNumber:
                                    index + 1

                                property bool active:
                                    workspaces.current
                                    === desktopNumber

                                width: 30
                                height: 30

                                radius: 5

                                color:
                                    active
                                        ? "#8cc6df"
                                        : workspaceMouse.containsMouse
                                            ? "#393e53"
                                            : "transparent"


                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }


                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        workspaceButton.desktopNumber

                                    color:
                                        workspaceButton.active
                                            ? "#181a1c"
                                            : "#7e8294"

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize: 13
                                    font.bold: true


                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 120
                                        }
                                    }
                                }


                                MouseArea {
                                    id: workspaceMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                        Qt.PointingHandCursor


                                    onClicked: {
                                        panelWindow.closeAllPopups()

                                        workspaces.switchTo(
                                            workspaceButton.desktopNumber
                                        )
                                    }
                                }
                            }
                        }
                    }
                }


                /*
                 * =================================================
                 * CENTER — DATE + TIME
                 * =================================================
                 */

                Rectangle {
                    id: clockIsland

                    anchors.centerIn: parent

                    width: 190
                    height: 40

                    radius: 6

                    color:
                        clockMouse.containsMouse
                            ? "#393e53"
                            : "#333648"

                    border.width: 1
                    border.color: "#393e53"


                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }


                    Row {
                        anchors.centerIn: parent

                        spacing: 10


                        Text {
                            text: Qt.formatDateTime(
                                clock.date,
                                "hh:mm"
                            )

                            color: "#e1e3e4"

                            font.family:
                                "JetBrains Mono"

                            font.pixelSize: 15
                            font.bold: true
                        }


                        Text {
                            text: Qt.formatDateTime(
                                clock.date,
                                "ddd dd.MM"
                            ).toUpperCase()

                            color: "#7e8294"

                            font.family:
                                "JetBrains Mono"

                            font.pixelSize: 11
                            font.bold: true
                        }
                    }


                    MouseArea {
                        id: clockMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor


                        onClicked: {
                            panelWindow.togglePopup(
                                calendarPopup
                            )
                        }
                    }
                }


                /*
                 * =================================================
                 * RIGHT — WIDGETS
                 * =================================================
                 */

                Rectangle {
                    id: rightIsland

                    anchors {
                        right: parent.right
                        rightMargin: 6
                        verticalCenter: parent.verticalCenter
                    }

                    width: rightRow.width + 10
                    height: 40

                    radius: 6
                    color: "#333648"

                    border.width: 1
                    border.color: "#393e53"


                    Row {
                        id: rightRow

                        anchors.centerIn: parent

                        spacing: 4


                        /*
                         * =========================================
                         * MEDIA
                         * =========================================
                         */

                        Rectangle {
                            id: mediaWidget

                            width: 214
                            height: 30

                            radius: 5

                            color:
                                media.available
                                    ? "#bb97ee"
                                    : "#5a5e7a"


                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }


                            Row {
                                anchors {
                                    fill: parent

                                    leftMargin: 10
                                    rightMargin: 10
                                }

                                spacing: 7


                                Text {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    text:
                                        media.playing
                                            ? "▶"
                                            : "♪"

                                    color:
                                        media.available
                                            ? "#181a1c"
                                            : "#e1e3e4"

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize: 11
                                    font.bold: true
                                }


                                Text {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width:
                                        parent.width - 30

                                    text:
                                        media.displayText

                                    elide:
                                        Text.ElideRight

                                    color:
                                        media.available
                                            ? "#181a1c"
                                            : "#e1e3e4"

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize: 12
                                    font.bold: true
                                }
                            }


                            MouseArea {
                                anchors.fill: parent

                                acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.RightButton

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: mouse => {
                                    if (
                                        mouse.button
                                        === Qt.LeftButton
                                    ) {
                                        panelWindow.togglePopup(
                                            mediaPopup
                                        )
                                    }

                                    if (
                                        mouse.button
                                        === Qt.RightButton
                                    ) {
                                        media.togglePlaying()
                                    }
                                }
                            }
                        }


                        /*
                         * =========================================
                         * CPU
                         * =========================================
                         */

                        Rectangle {
                            width: 72
                            height: 30

                            radius: 5
                            color: "#c5a8dc"


                            Text {
                                anchors.centerIn: parent

                                text:
                                    "CPU "
                                    + stats.cpuUsage
                                    + "%"

                                color: "#181a1c"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }
                        }


                        /*
                         * =========================================
                         * TEMPERATURE
                         * =========================================
                         */

                        Rectangle {
                            width: 46
                            height: 30

                            radius: 5
                            color: "#df8f9d"


                            Text {
                                anchors.centerIn: parent

                                text:
                                    stats.cpuTemp
                                    + "°"

                                color: "#181a1c"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }
                        }


                        /*
                         * =========================================
                         * WIFI
                         * =========================================
                         */

                        Rectangle {
                            id: wifiWidget

                            width: 62
                            height: 30

                            radius: 5


                            color:
                                network.wifiConnected
                                    ? "#8cc6df"
                                    : network.wifiEnabled
                                        ? "#5a5e7a"
                                        : "#333648"


                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text: "WiFi"

                                color:
                                    network.wifiConnected
                                        ? "#181a1c"
                                        : "#e1e3e4"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.togglePopup(
                                        wifiPopup
                                    )
                                }
                            }
                        }


                        /*
                         * =========================================
                         * BLUETOOTH
                         * =========================================
                         */

                        Rectangle {
                            id: bluetoothWidget

                            width:
                                bluetooth.connectedCount > 0
                                    ? 52
                                    : 36

                            height: 30

                            radius: 5


                            color:
                                bluetooth.connectedCount > 0
                                    ? "#8cc6df"
                                    : bluetooth.enabled
                                        ? "#93b6d9"
                                        : "#333648"


                            Behavior on width {
                                NumberAnimation {
                                    duration: 150
                                }
                            }


                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text:
                                    bluetooth.connectedCount > 0
                                        ? "BT "
                                            + bluetooth.connectedCount
                                        : "BT"

                                color:
                                    bluetooth.enabled
                                        ? "#181a1c"
                                        : "#e1e3e4"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.togglePopup(
                                        bluetoothPopup
                                    )
                                }
                            }
                        }


                        /*
                         * =========================================
                         * VOLUME
                         * =========================================
                         */

                        Rectangle {
                            id: volumeWidget

                            width:
                                audio.muted
                                    ? 52
                                    : 44

                            height: 30

                            radius: 5


                            color:
                                audio.available
                                    ? audio.muted
                                        ? "#5a5e7a"
                                        : "#acd681"
                                    : "#333648"


                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }
                            }


                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text:
                                    audio.available
                                        ? audio.muted
                                            ? "MUTE"
                                            : audio.volume
                                        : "--"

                                color:
                                    audio.muted
                                        ? "#e1e3e4"
                                        : "#181a1c"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.RightButton

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: mouse => {
                                    if (
                                        mouse.button
                                        === Qt.LeftButton
                                    ) {
                                        panelWindow.togglePopup(
                                            audioPopup
                                        )
                                    }

                                    if (
                                        mouse.button
                                        === Qt.RightButton
                                    ) {
                                        audio.toggleMute()
                                    }
                                }


                                onWheel: wheel => {
                                    if (
                                        wheel.angleDelta.y > 0
                                    ) {
                                        audio.increase()
                                    } else if (
                                        wheel.angleDelta.y < 0
                                    ) {
                                        audio.decrease()
                                    }

                                    wheel.accepted = true
                                }
                            }
                        }


                        /*
                         * =========================================
                         * KEYBOARD
                         * =========================================
                         */

                        Rectangle {
                            id: keyboardWidget

                            width:
                                keyboard.lockSuffix.length === 0
                                    ? 40
                                    : keyboard.lockSuffix.length === 1
                                        ? 54
                                        : 64

                            height: 30

                            radius: 5
                            color: "#dbc77a"


                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text:
                                    keyboard.displayLabel

                                color: "#181a1c"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.closeAllPopups()

                                    keyboard.nextLayout()
                                }
                            }
                        }


                        /*
                         * =========================================
                         * UPDATES
                         * =========================================
                         */

                        Rectangle {
                            id: updateWidget

                            width:
                                updates.totalCount < 10
                                    ? 44
                                    : updates.totalCount < 100
                                        ? 52
                                        : 60

                            height: 30

                            radius: 5


                            color:
                                updates.totalCount > 0
                                    ? "#9ca6bd"
                                    : "#5a5e7a"


                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }
                            }


                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text:
                                    updates.checking
                                        ? "↻ …"
                                        : "↻ "
                                            + updates.totalCount

                                color:
                                    updates.totalCount > 0
                                        ? "#181a1c"
                                        : "#e1e3e4"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.togglePopup(
                                        updatesPopup
                                    )
                                }
                            }
                        }


                        /*
                         * =========================================
                         * BATTERY
                         * =========================================
                         */

                        Rectangle {
                            id: batteryWidget

                            width:
                                battery.charging
                                    ? 72
                                    : 60

                            height: 30

                            radius: 5


                            color:
                                !battery.available
                                    ? "#333648"
                                    : battery.percentage <= 15
                                        ? "#fb617e"
                                        : battery.percentage <= 35
                                            ? "#edc763"
                                            : "#acd681"


                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }
                            }


                            Behavior on color {
                                ColorAnimation {
                                    duration: 180
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text:
                                    !battery.available
                                        ? "--"
                                        : battery.charging
                                            ? "⚡ "
                                                + battery.percentage
                                                + "%"
                                            : battery.percentage
                                                + "%"

                                color:
                                    battery.available
                                        ? "#181a1c"
                                        : "#e1e3e4"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 12
                                font.bold: true
                            }


                            MouseArea {
                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.togglePopup(
                                        batteryPopup
                                    )
                                }
                            }
                        }


                        /*
                         * =========================================
                         * POWER
                         * =========================================
                         */

                        Rectangle {
                            id: powerWidget

                            width: 36
                            height: 30

                            radius: 5

                            color:
                                powerMouse.containsMouse
                                    ? "#ff7897"
                                    : "#fb617e"


                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }


                            Text {
                                anchors.centerIn: parent

                                text: "⏻"

                                color: "#ffffff"

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize: 14
                                font.bold: true
                            }


                            MouseArea {
                                id: powerMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: {
                                    panelWindow.togglePopup(
                                        powerPopup
                                    )
                                }
                            }
                        }
                    }
                }
            }


            /*
             * ====================================================
             * POPUPS
             * ====================================================
             */

            AudioPopup {
                id: audioPopup

                anchorItem: volumeWidget
                audioService: audio

                visible: false
            }


            WifiPopup {
                id: wifiPopup

                anchorItem: wifiWidget
                networkService: network

                visible: false
            }


            BluetoothPopup {
                id: bluetoothPopup

                anchorItem: bluetoothWidget
                bluetoothService: bluetooth

                visible: false
            }


            BatteryPopup {
                id: batteryPopup

                anchorItem: batteryWidget
                batteryService: battery

                visible: false
            }


            UpdatesPopup {
                id: updatesPopup

                anchorItem: updateWidget
                updateService: updates

                visible: false
            }


            MediaPopup {
                id: mediaPopup

                anchorItem: mediaWidget
                mediaService: media

                visible: false
            }


            PowerPopup {
                id: powerPopup

                anchorItem: powerWidget

                visible: false
            }


            CalendarPopup {
                id: calendarPopup

                anchorItem: clockIsland
                clockService: clock

                visible: false
            }
        }
    }
}

import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem
    required property var batteryService

    implicitWidth: 330
    implicitHeight: 270

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    function formatTime(seconds) {
        if (seconds <= 0) {
            return "—"
        }

        const totalMinutes =
            Math.round(seconds / 60)

        const hours =
            Math.floor(totalMinutes / 60)

        const minutes =
            totalMinutes % 60

        if (hours <= 0) {
            return minutes + " min"
        }

        if (minutes === 0) {
            return hours + " h"
        }

        return hours + " h " + minutes + " min"
    }


    function stateText() {
        if (!root.batteryService.available) {
            return "Nedostupná"
        }

        if (root.batteryService.fullyCharged) {
            return "Plně nabito"
        }

        if (root.batteryService.charging) {
            return "Nabíjení"
        }

        if (root.batteryService.discharging) {
            return "Vybíjení"
        }

        return "Neznámý stav"
    }


    function stateColor() {
        if (!root.batteryService.available) {
            return "#7e8294"
        }

        if (root.batteryService.charging) {
            return "#6dcae8"
        }

        if (root.batteryService.fullyCharged) {
            return "#9ed06c"
        }

        if (root.batteryService.percentage <= 15) {
            return "#fb617e"
        }

        if (root.batteryService.percentage <= 35) {
            return "#edc763"
        }

        return "#9ed06c"
    }


    function batteryColor() {
        if (!root.batteryService.available) {
            return "#5a5e7a"
        }

        if (root.batteryService.percentage <= 15) {
            return "#fb617e"
        }

        if (root.batteryService.percentage <= 35) {
            return "#edc763"
        }

        return "#9ed06c"
    }


    Rectangle {
        anchors.fill: parent

        radius: 9

        color: "#2b2d3a"

        border.width: 1
        border.color: "#3f445b"


        Text {
            id: title

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Battery"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Text {
            anchors {
                top: parent.top
                right: parent.right

                topMargin: 14
                rightMargin: 16
            }

            text:
                root.batteryService.available
                    ? root.batteryService.percentage
                        + " %"
                    : "--"

            color:
                root.batteryColor()

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Rectangle {
            id: batteryTrack

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 19
                leftMargin: 16
                rightMargin: 16
            }

            height: 14

            radius: 7

            color: "#393e53"


            Rectangle {
                width:
                    parent.width
                    * Math.max(
                        0,
                        Math.min(
                            1,
                            root.batteryService.percentage
                            / 100
                        )
                    )

                height: parent.height

                radius: 7

                color:
                    root.batteryColor()


                Behavior on width {
                    NumberAnimation {
                        duration: 250
                    }
                }


                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }
        }


        Column {
            anchors {
                top: batteryTrack.bottom
                left: parent.left
                right: parent.right

                topMargin: 20
                leftMargin: 16
                rightMargin: 16
            }

            spacing: 9


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Stav"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.stateText()

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.stateColor()

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Nabití"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.available
                            ? root.batteryService.percentage
                                + " %"
                            : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text: "Kondice"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.healthAvailable
                            ? root.batteryService.health
                                + " %"
                            : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.batteryService.healthAvailable
                            ? root.batteryService.health >= 80
                                ? "#9ed06c"
                                : root.batteryService.health >= 60
                                    ? "#edc763"
                                    : "#fb617e"
                            : "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }


            Row {
                width: parent.width
                height: 18

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.charging
                            ? "Do nabití"
                            : root.batteryService.discharging
                                ? "Zbývá"
                                : "Napájení"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width / 2

                    text:
                        root.batteryService.charging
                            ? root.formatTime(
                                root.batteryService.timeToFull
                            )
                            : root.batteryService.discharging
                                ? root.formatTime(
                                    root.batteryService.timeToEmpty
                                )
                                : root.batteryService.fullyCharged
                                    ? "Adaptér"
                                    : "—"

                    horizontalAlignment:
                        Text.AlignRight

                    color:
                        root.batteryService.charging
                            ? "#6dcae8"
                            : "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }


        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 16
                rightMargin: 16
                bottomMargin: 14
            }

            height: 34

            radius: 6

            color:
                root.batteryService.charging
                    ? "#354157"
                    : root.batteryService.fullyCharged
                        ? "#394634"
                        : "#333648"


            Text {
                anchors.centerIn: parent

                text:
                    root.batteryService.charging
                        ? "⚡  Napájení připojeno"
                        : root.batteryService.fullyCharged
                            ? "✓  Baterie je plně nabitá"
                            : "◌  Provoz na baterii"

                color:
                    root.batteryService.charging
                        ? "#6dcae8"
                        : root.batteryService.fullyCharged
                            ? "#9ed06c"
                            : "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.bold: true
            }
        }
    }
}

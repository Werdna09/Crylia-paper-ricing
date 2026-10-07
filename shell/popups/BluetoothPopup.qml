import QtQuick
import Quickshell
import Quickshell.Bluetooth

PopupWindow {
    id: root

    required property Item anchorItem
    required property var bluetoothService

    implicitWidth: 360
    implicitHeight: 420

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


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

            text: "Bluetooth"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Rectangle {
            anchors {
                right: parent.right
                verticalCenter:
                    title.verticalCenter

                rightMargin: 16
            }

            width: 44
            height: 24

            radius: 12

            color:
                root.bluetoothService.enabled
                    ? "#93b6d9"
                    : "#393e53"


            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }


            Rectangle {
                width: 18
                height: 18

                radius: 9

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    root.bluetoothService.enabled
                        ? parent.width - width - 3
                        : 3

                color:
                    root.bluetoothService.enabled
                        ? "#181a1c"
                        : "#7e8294"


                Behavior on x {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }


            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.bluetoothService
                        .toggleEnabled()
                }
            }
        }


        Rectangle {
            id: statusCard

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 14
                leftMargin: 14
                rightMargin: 14
            }

            height: 58

            radius: 7

            color:
                root.bluetoothService.enabled
                    ? "#354157"
                    : "#333648"

            border.width: 1

            border.color:
                root.bluetoothService.enabled
                    ? "#6dcae8"
                    : "#393e53"


            Text {
                anchors {
                    top: parent.top
                    left: parent.left

                    topMargin: 10
                    leftMargin: 12
                }

                text:
                    !root.bluetoothService.available
                        ? "Bluetooth není dostupný"
                        : root.bluetoothService.enabled
                            ? "Bluetooth zapnutý"
                            : "Bluetooth vypnutý"

                color: "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
            }


            Text {
                anchors {
                    bottom: parent.bottom
                    left: parent.left

                    bottomMargin: 9
                    leftMargin: 12
                }

                text:
                    root.bluetoothService.connectedCount === 0
                        ? "Žádné připojené zařízení"
                        : root.bluetoothService.connectedCount === 1
                            ? "1 připojené zařízení"
                            : root.bluetoothService.connectedCount
                                + " připojená zařízení"

                color:
                    root.bluetoothService.connectedCount > 0
                        ? "#6dcae8"
                        : "#7e8294"

                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }
        }


        Text {
            id: devicesTitle

            anchors {
                top: statusCard.bottom
                left: parent.left

                topMargin: 14
                leftMargin: 16
            }

            text: "Zařízení"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        Rectangle {
            anchors {
                right: parent.right
                verticalCenter:
                    devicesTitle.verticalCenter

                rightMargin: 14
            }

            width: 82
            height: 26

            radius: 5

            color:
                root.bluetoothService.discovering
                    ? "#bb97ee"
                    : "#333648"


            Text {
                anchors.centerIn: parent

                text:
                    root.bluetoothService.discovering
                        ? "STOP"
                        : "HLEDAT"

                color:
                    root.bluetoothService.discovering
                        ? "#181a1c"
                        : "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.bold: true
            }


            MouseArea {
                anchors.fill: parent

                enabled:
                    root.bluetoothService.enabled

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.bluetoothService
                        .toggleDiscovery()
                }
            }
        }


        ListView {
            id: deviceList

            anchors {
                top: devicesTitle.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                topMargin: 10
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            spacing: 3
            clip: true

            model:
                root.bluetoothService.enabled
                    ? root.bluetoothService.devices
                    : null


            delegate: Rectangle {
                id: deviceRow

                required property var modelData

                width: ListView.view.width
                height: 58

                radius: 6

                color:
                    modelData.connected
                        ? "#354157"
                        : deviceMouse.containsMouse
                            ? "#333648"
                            : "transparent"

                border.width:
                    modelData.connected
                        ? 1
                        : 0

                border.color: "#6dcae8"


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: actionButton.left

                        topMargin: 8
                        leftMargin: 9
                        rightMargin: 8
                    }

                    text:
                        modelData.name.length > 0
                            ? modelData.name
                            : modelData.address

                    elide: Text.ElideRight

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: modelData.connected
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left

                        bottomMargin: 8
                        leftMargin: 9
                    }

                    text:
                        modelData.connected
                            ? (
                                modelData.batteryAvailable
                                    ? "Připojeno · "
                                        + Math.round(
                                            modelData.battery
                                            * 100
                                        )
                                        + "%"
                                    : "Připojeno"
                            )
                            : modelData.pairing
                                ? "Párování…"
                                : modelData.paired
                                    ? "Spárováno"
                                    : "Nové zařízení"

                    color:
                        modelData.connected
                            ? "#6dcae8"
                            : modelData.paired
                                ? "#9ed06c"
                                : "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                Rectangle {
                    id: actionButton

                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 8
                    }

                    width: 82
                    height: 30

                    radius: 5

                    color:
                        modelData.connected
                            ? "#55393d"
                            : modelData.paired
                                ? "#354157"
                                : "#423f59"


                    Text {
                        anchors.centerIn: parent

                        text:
                            modelData.connected
                                ? "ODPOJIT"
                                : modelData.pairing
                                    ? "ZRUŠIT"
                                    : modelData.paired
                                        ? "PŘIPOJIT"
                                        : "PÁROVAT"

                        color:
                            modelData.connected
                                ? "#fb617e"
                                : modelData.paired
                                    ? "#6dcae8"
                                    : "#bb97ee"

                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        font.bold: true
                    }


                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            if (
                                deviceRow.modelData.connected
                            ) {
                                deviceRow.modelData
                                    .disconnect()

                                return
                            }

                            if (
                                deviceRow.modelData.pairing
                            ) {
                                deviceRow.modelData
                                    .cancelPair()

                                return
                            }

                            if (
                                deviceRow.modelData.paired
                            ) {
                                deviceRow.modelData
                                    .connect()

                                return
                            }

                            deviceRow.modelData.pair()
                        }
                    }
                }


                MouseArea {
                    id: deviceMouse

                    anchors {
                        left: parent.left
                        right: actionButton.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (
                            deviceRow.modelData.connected
                        ) {
                            deviceRow.modelData.disconnect()
                        } else if (
                            deviceRow.modelData.paired
                        ) {
                            deviceRow.modelData.connect()
                        }
                    }
                }
            }
        }


        Text {
            visible:
                root.bluetoothService.enabled
                && deviceList.count === 0

            anchors.centerIn: deviceList

            text:
                root.bluetoothService.discovering
                    ? "Hledám zařízení…"
                    : "Žádná zařízení"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 11
        }
    }


    onVisibleChanged: {
        if (visible) {
            if (
                root.bluetoothService.enabled
            ) {
                root.bluetoothService
                    .startDiscovery()
            }
        } else {
            root.bluetoothService
                .stopDiscovery()
        }
    }
}

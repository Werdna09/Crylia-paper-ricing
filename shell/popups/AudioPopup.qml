import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem
    required property var audioService

    implicitWidth: 300
    implicitHeight: 148

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
                topMargin: 14
                leftMargin: 16
            }

            text: "Audio"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 14
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
                !root.audioService.available
                    ? "--"
                    : root.audioService.muted
                        ? "MUTED"
                        : root.audioService.volume + " %"

            color:
                root.audioService.muted
                    ? "#fb617e"
                    : "#acd681"

            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: true
        }


        Text {
            id: deviceName

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 5
                leftMargin: 16
                rightMargin: 16
            }

            text:
                root.audioService.available
                    ? (
                        root.audioService.sink.description.length > 0
                            ? root.audioService.sink.description
                            : root.audioService.sink.name
                    )
                    : "No audio output"

            elide: Text.ElideRight

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 9
        }


        Rectangle {
            id: volumeTrack

            anchors {
                top: deviceName.bottom
                left: parent.left
                right: parent.right

                topMargin: 15
                leftMargin: 16
                rightMargin: 16
            }

            height: 8

            radius: 4

            color: "#393e53"


            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                width:
                    parent.width
                    * Math.max(
                        0,
                        Math.min(
                            1,
                            root.audioService.volume / 100
                        )
                    )

                radius: 4

                color:
                    root.audioService.muted
                        ? "#5a5e7a"
                        : "#acd681"

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }


            Rectangle {
                width: 14
                height: 14

                radius: 7

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    Math.max(
                        0,
                        Math.min(
                            volumeTrack.width - width,
                            volumeTrack.width
                            * root.audioService.volume
                            / 100
                            - width / 2
                        )
                    )

                color: "#e1e3e4"

                Behavior on x {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }


            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                height: 28

                cursorShape: Qt.PointingHandCursor


                function setVolume(mouseX) {
                    const value =
                        Math.max(
                            0,
                            Math.min(
                                1,
                                mouseX / width
                            )
                        )

                    root.audioService.setVolume(value)
                }


                onPressed: mouse => {
                    setVolume(mouse.x)
                }


                onPositionChanged: mouse => {
                    if (pressed) {
                        setVolume(mouse.x)
                    }
                }


                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        root.audioService.increase()
                    } else if (wheel.angleDelta.y < 0) {
                        root.audioService.decrease()
                    }

                    wheel.accepted = true
                }
            }
        }


        Row {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 16
                rightMargin: 16
                bottomMargin: 12
            }

            spacing: 6


            Rectangle {
                width: 70
                height: 30

                radius: 5
                color: "#333648"

                Text {
                    anchors.centerIn: parent

                    text: "-5%"

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.decrease()
                    }
                }
            }


            Rectangle {
                width: 122
                height: 30

                radius: 5

                color:
                    root.audioService.muted
                        ? "#55393d"
                        : "#394634"

                Text {
                    anchors.centerIn: parent

                    text:
                        root.audioService.muted
                            ? "UNMUTE"
                            : "MUTE"

                    color:
                        root.audioService.muted
                            ? "#fb617e"
                            : "#acd681"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.toggleMute()
                    }
                }
            }


            Rectangle {
                width: 70
                height: 30

                radius: 5
                color: "#333648"

                Text {
                    anchors.centerIn: parent

                    text: "+5%"

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.audioService.increase()
                    }
                }
            }
        }
    }
}

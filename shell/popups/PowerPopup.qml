import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem

    property string pendingAction: ""
    property string pendingLabel: ""
    property color pendingColor: "#fb617e"

    implicitWidth: 340
    implicitHeight: 330

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    /*
     * ============================================================
     * ACTIONS
     * ============================================================
     */

    function lockScreen() {
        root.visible = false

        Quickshell.execDetached([
            "qdbus6",
            "org.freedesktop.ScreenSaver",
            "/ScreenSaver",
            "org.freedesktop.ScreenSaver.Lock"
        ])
    }


    function suspendSystem() {
        root.visible = false

        Quickshell.execDetached([
            "systemctl",
            "suspend"
        ])
    }


    function requestAction(action, label, color) {
        root.pendingAction = action
        root.pendingLabel = label
        root.pendingColor = color
    }


    function cancelAction() {
        root.pendingAction = ""
        root.pendingLabel = ""
    }


    function confirmAction() {
        const action =
            root.pendingAction

        root.pendingAction = ""
        root.pendingLabel = ""

        root.visible = false


        if (action === "logout") {
            Quickshell.execDetached([
                "qdbus6",
                "org.kde.Shutdown",
                "/Shutdown",
                "org.kde.Shutdown.logout"
            ])

            return
        }


        if (action === "reboot") {
            Quickshell.execDetached([
                "qdbus6",
                "org.kde.Shutdown",
                "/Shutdown",
                "org.kde.Shutdown.logoutAndReboot"
            ])

            return
        }


        if (action === "shutdown") {
            Quickshell.execDetached([
                "qdbus6",
                "org.kde.Shutdown",
                "/Shutdown",
                "org.kde.Shutdown.logoutAndShutdown"
            ])
        }
    }


    /*
     * ============================================================
     * MAIN WINDOW
     * ============================================================
     */

    Rectangle {
        anchors.fill: parent

        radius: 9

        color: "#2b2d3a"

        border.width: 1
        border.color: "#3f445b"


        /*
         * ========================================================
         * HEADER
         * ========================================================
         */

        Text {
            id: title

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Power"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Text {
            anchors {
                right: parent.right
                verticalCenter:
                    title.verticalCenter

                rightMargin: 16
            }

            text: "CRYLIA"

            color: "#5a5e7a"

            font.family: "JetBrains Mono"
            font.pixelSize: 9
            font.bold: true
        }


        /*
         * ========================================================
         * QUICK ACTIONS
         * ========================================================
         */

        Row {
            id: quickActions

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 18
                leftMargin: 14
                rightMargin: 14
            }

            spacing: 8


            /*
             * LOCK
             */

            Rectangle {
                width:
                    (quickActions.width - 8) / 2

                height: 72

                radius: 7

                color:
                    lockMouse.containsMouse
                        ? "#354157"
                        : "#333648"

                border.width: 1

                border.color:
                    lockMouse.containsMouse
                        ? "#6dcae8"
                        : "#393e53"


                Text {
                    anchors {
                        top: parent.top
                        horizontalCenter:
                            parent.horizontalCenter

                        topMargin: 11
                    }

                    text: "LOCK"

                    color: "#6dcae8"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter:
                            parent.horizontalCenter

                        bottomMargin: 11
                    }

                    text: "Zamknout obrazovku"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                MouseArea {
                    id: lockMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.lockScreen()
                    }
                }
            }


            /*
             * SLEEP
             */

            Rectangle {
                width:
                    (quickActions.width - 8) / 2

                height: 72

                radius: 7

                color:
                    sleepMouse.containsMouse
                        ? "#423f59"
                        : "#333648"

                border.width: 1

                border.color:
                    sleepMouse.containsMouse
                        ? "#bb97ee"
                        : "#393e53"


                Text {
                    anchors {
                        top: parent.top
                        horizontalCenter:
                            parent.horizontalCenter

                        topMargin: 11
                    }

                    text: "SLEEP"

                    color: "#bb97ee"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter:
                            parent.horizontalCenter

                        bottomMargin: 11
                    }

                    text: "Uspat počítač"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                MouseArea {
                    id: sleepMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.suspendSystem()
                    }
                }
            }
        }


        /*
         * ========================================================
         * SESSION ACTIONS
         * ========================================================
         */

        Column {
            id: sessionActions

            anchors {
                top: quickActions.bottom
                left: parent.left
                right: parent.right

                topMargin: 12
                leftMargin: 14
                rightMargin: 14
            }

            spacing: 7


            /*
             * LOGOUT
             */

            Rectangle {
                width: parent.width
                height: 46

                radius: 6

                color:
                    logoutMouse.containsMouse
                        ? "#4e432f"
                        : "#333648"


                Text {
                    anchors {
                        left: parent.left
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 12
                    }

                    text: "LOGOUT"

                    color: "#edc763"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text: "Odhlásit relaci"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                MouseArea {
                    id: logoutMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.requestAction(
                            "logout",
                            "Odhlásit uživatele?",
                            "#edc763"
                        )
                    }
                }
            }


            /*
             * RESTART
             */

            Rectangle {
                width: parent.width
                height: 46

                radius: 6

                color:
                    restartMouse.containsMouse
                        ? "#354157"
                        : "#333648"


                Text {
                    anchors {
                        left: parent.left
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 12
                    }

                    text: "RESTART"

                    color: "#6dcae8"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text: "Restartovat systém"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                MouseArea {
                    id: restartMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.requestAction(
                            "reboot",
                            "Restartovat počítač?",
                            "#6dcae8"
                        )
                    }
                }
            }


            /*
             * SHUTDOWN
             */

            Rectangle {
                width: parent.width
                height: 46

                radius: 6

                color:
                    shutdownMouse.containsMouse
                        ? "#55393d"
                        : "#333648"


                Text {
                    anchors {
                        left: parent.left
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 12
                    }

                    text: "SHUTDOWN"

                    color: "#fb617e"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text: "Vypnout počítač"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                MouseArea {
                    id: shutdownMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.requestAction(
                            "shutdown",
                            "Vypnout počítač?",
                            "#fb617e"
                        )
                    }
                }
            }
        }


        /*
         * ========================================================
         * CONFIRMATION OVERLAY
         * ========================================================
         */

        Rectangle {
            id: confirmPanel

            visible:
                root.pendingAction.length > 0

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            height: 84

            radius: 7

            color: "#252630"

            border.width: 1
            border.color:
                root.pendingColor


            Text {
                anchors {
                    top: parent.top
                    horizontalCenter:
                        parent.horizontalCenter

                    topMargin: 10
                }

                text:
                    root.pendingLabel

                color:
                    root.pendingColor

                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true
            }


            Row {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter:
                        parent.horizontalCenter

                    bottomMargin: 9
                }

                spacing: 8


                Rectangle {
                    width: 120
                    height: 32

                    radius: 5

                    color: "#333648"


                    Text {
                        anchors.centerIn: parent

                        text: "ZRUŠIT"

                        color: "#e1e3e4"

                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        font.bold: true
                    }


                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            root.cancelAction()
                        }
                    }
                }


                Rectangle {
                    width: 120
                    height: 32

                    radius: 5

                    color:
                        root.pendingColor


                    Text {
                        anchors.centerIn: parent

                        text: "POTVRDIT"

                        color: "#181a1c"

                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                        font.bold: true
                    }


                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            root.confirmAction()
                        }
                    }
                }
            }
        }
    }


    /*
     * ============================================================
     * RESET
     * ============================================================
     */

    onVisibleChanged: {
        if (!visible) {
            root.cancelAction()
        }
    }
}

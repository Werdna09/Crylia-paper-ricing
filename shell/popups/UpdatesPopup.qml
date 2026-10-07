import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    required property Item anchorItem
    required property var updateService

    property var repoEntries: []
    property var aurEntries: []

    readonly property var allEntries:
        repoEntries.concat(aurEntries)

    readonly property bool checkingDetails:
        repoProcess.running
        || aurProcess.running

    implicitWidth: 430
    implicitHeight: 470

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    function parseOutput(text, source) {
        const output = text.trim()

        if (output.length === 0) {
            return []
        }

        const lines =
            output
                .split("\n")
                .filter(
                    line =>
                        line.trim().length > 0
                )

        const result = []

        for (const rawLine of lines) {
            const line = rawLine.trim()

            const match =
                line.match(
                    /^(\S+)\s+(\S+)\s+->\s+(\S+)$/
                )

            if (match !== null) {
                result.push({
                    name: match[1],
                    oldVersion: match[2],
                    newVersion: match[3],
                    source: source
                })
            } else {
                result.push({
                    name: line,
                    oldVersion: "",
                    newVersion: "",
                    source: source
                })
            }
        }

        return result
    }


    function refreshDetails() {
        if (!repoProcess.running) {
            repoProcess.running = true
        }

        if (!aurProcess.running) {
            aurProcess.running = true
        }
    }


    function runUpgrade() {
        Quickshell.execDetached([
            "alacritty",
            "-e",
            "fish",
            "-lc",
            "paru -Syu"
        ])
    }


    Process {
        id: repoProcess

        command: [
            "checkupdates"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.repoEntries =
                    root.parseOutput(
                        text,
                        "REPO"
                    )
            }
        }
    }


    Process {
        id: aurProcess

        command: [
            "paru",
            "-Qua"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.aurEntries =
                    root.parseOutput(
                        text,
                        "AUR"
                    )
            }
        }
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

            text: "Updates"

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
                root.updateService.checking
                    ? "…"
                    : root.updateService.totalCount

            color:
                root.updateService.totalCount > 0
                    ? "#9ca6bd"
                    : "#9ed06c"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Row {
            id: summaryRow

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 16
                leftMargin: 14
                rightMargin: 14
            }

            spacing: 8


            Rectangle {
                width:
                    (summaryRow.width - 8) / 2

                height: 54

                radius: 7

                color: "#333648"

                border.width: 1
                border.color: "#393e53"


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left

                        topMargin: 8
                        leftMargin: 10
                    }

                    text: "REPO"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text:
                        root.updateService.repoCount

                    color: "#6dcae8"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.bold: true
                }
            }


            Rectangle {
                width:
                    (summaryRow.width - 8) / 2

                height: 54

                radius: 7

                color: "#333648"

                border.width: 1
                border.color: "#393e53"


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left

                        topMargin: 8
                        leftMargin: 10
                    }

                    text: "AUR"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                Text {
                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 12
                    }

                    text:
                        root.updateService.aurCount

                    color: "#bb97ee"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 18
                    font.bold: true
                }
            }
        }


        Text {
            id: listTitle

            anchors {
                top: summaryRow.bottom
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text:
                root.checkingDetails
                    ? "Kontroluji balíčky…"
                    : "Balíčky"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        Rectangle {
            id: refreshButton

            anchors {
                right: parent.right
                verticalCenter:
                    listTitle.verticalCenter

                rightMargin: 14
            }

            width: 82
            height: 26

            radius: 5

            color:
                root.checkingDetails
                    ? "#423f59"
                    : "#333648"


            Text {
                anchors.centerIn: parent

                text:
                    root.checkingDetails
                        ? "ČEKÁM…"
                        : "OBNOVIT"

                color:
                    root.checkingDetails
                        ? "#bb97ee"
                        : "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.bold: true
            }


            MouseArea {
                anchors.fill: parent

                enabled:
                    !root.checkingDetails

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.refreshDetails()
                }
            }
        }


        ListView {
            id: updateList

            anchors {
                top: listTitle.bottom
                left: parent.left
                right: parent.right
                bottom: actionRow.top

                topMargin: 9
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            clip: true
            spacing: 3

            model: root.allEntries


            delegate: Rectangle {
                required property var modelData

                width: ListView.view.width
                height: 52

                radius: 6

                color:
                    updateMouse.containsMouse
                        ? "#333648"
                        : "transparent"


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: sourceBadge.left

                        topMargin: 7
                        leftMargin: 9
                        rightMargin: 8
                    }

                    text: modelData.name

                    elide: Text.ElideRight

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                Text {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right

                        bottomMargin: 7
                        leftMargin: 9
                        rightMargin: 9
                    }

                    text:
                        modelData.oldVersion.length > 0
                            ? modelData.oldVersion
                                + "  →  "
                                + modelData.newVersion
                            : "Aktualizace dostupná"

                    elide: Text.ElideRight

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                Rectangle {
                    id: sourceBadge

                    anchors {
                        right: parent.right
                        top: parent.top

                        rightMargin: 8
                        topMargin: 7
                    }

                    width: 42
                    height: 18

                    radius: 4

                    color:
                        modelData.source === "AUR"
                            ? "#423f59"
                            : "#354157"


                    Text {
                        anchors.centerIn: parent

                        text:
                            modelData.source

                        color:
                            modelData.source === "AUR"
                                ? "#bb97ee"
                                : "#6dcae8"

                        font.family: "JetBrains Mono"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }


                MouseArea {
                    id: updateMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    acceptedButtons:
                        Qt.NoButton
                }
            }
        }


        Text {
            visible:
                !root.checkingDetails
                && updateList.count === 0

            anchors.centerIn: updateList

            text: "Systém je aktuální ✓"

            color: "#9ed06c"

            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: true
        }


        Row {
            id: actionRow

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 14
                rightMargin: 14
                bottomMargin: 12
            }

            spacing: 8


            Rectangle {
                width: 125
                height: 34

                radius: 6

                color: "#333648"


                Text {
                    anchors.centerIn: parent

                    text: "OBNOVIT"

                    color: "#e1e3e4"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        !root.checkingDetails

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.refreshDetails()
                    }
                }
            }


            Rectangle {
                width:
                    actionRow.width
                    - 133

                height: 34

                radius: 6

                color:
                    root.updateService.totalCount > 0
                        ? "#9ca6bd"
                        : "#394634"


                Text {
                    anchors.centerIn: parent

                    text:
                        root.updateService.totalCount > 0
                            ? "AKTUALIZOVAT"
                            : "AKTUÁLNÍ"

                    color:
                        root.updateService.totalCount > 0
                            ? "#181a1c"
                            : "#9ed06c"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.updateService.totalCount > 0

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.runUpgrade()
                    }
                }
            }
        }
    }


    onVisibleChanged: {
        if (visible) {
            root.refreshDetails()
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Widgets


PopupWindow {
    id: root

    required property Item anchorItem

    property string query: ""

    /*
     * ============================================================
     * WINDOW
     * ============================================================
     */

    implicitWidth: 520
    implicitHeight: 520

    color: "transparent"

    grabFocus: true


    /*
     * Otevře se nad tlačítkem v docku.
     */

    anchor.item:
        root.anchorItem

    anchor.rect.x:
        Math.round(
            (
                root.anchorItem.width
                - root.implicitWidth
            ) / 2
        )

    anchor.rect.y:
        -8

    anchor.edges:
        Edges.Top | Edges.Left

    anchor.gravity:
        Edges.Top | Edges.Right

    anchor.adjustment:
        PopupAdjustment.SlideX
        | PopupAdjustment.FlipY


    /*
     * ============================================================
     * APPLICATION FILTER
     * ============================================================
     */

    function filteredApplications() {
        const text =
            root.query
                .trim()
                .toLowerCase()


        let applications =
            [
                ...DesktopEntries
                    .applications
                    .values
            ]


        if (text !== "") {
            applications =
                applications.filter(
                    entry => {
                        const name =
                            String(
                                entry.name || ""
                            ).toLowerCase()

                        const genericName =
                            String(
                                entry.genericName || ""
                            ).toLowerCase()

                        const comment =
                            String(
                                entry.comment || ""
                            ).toLowerCase()

                        const id =
                            String(
                                entry.id || ""
                            ).toLowerCase()


                        let keywords = ""

                        if (entry.keywords) {
                            keywords =
                                entry.keywords
                                    .join(" ")
                                    .toLowerCase()
                        }


                        return (
                            name.includes(text)
                            || genericName.includes(text)
                            || comment.includes(text)
                            || id.includes(text)
                            || keywords.includes(text)
                        )
                    }
                )
        }


        applications.sort(
            (a, b) =>
                String(a.name || "")
                    .localeCompare(
                        String(b.name || "")
                    )
        )


        /*
         * Launcher zbytečně neplníme
         * stovkami položek.
         */

        return applications.slice(
            0,
            12
        )
    }


    function launch(entry) {
        if (
            entry === null
            || entry === undefined
        ) {
            return
        }


        entry.execute()

        root.visible = false
    }


    function launchCurrent() {
        const applications =
            root.filteredApplications()


        if (applications.length === 0) {
            return
        }


        let index =
            applicationList.currentIndex


        if (
            index < 0
            || index >= applications.length
        ) {
            index = 0
        }


        root.launch(
            applications[index]
        )
    }


    /*
     * ============================================================
     * MODEL
     * ============================================================
     */

    ScriptModel {
        id: applicationModel

        values:
            root.filteredApplications()

        objectProp:
            "id"
    }


    /*
     * ============================================================
     * BACKGROUND
     * ============================================================
     */

    Rectangle {
        anchors.fill: parent

        radius: 12

        color: "#2b2d3a"

        border.width: 1
        border.color: "#3f445b"


        /*
         * ========================================================
         * HEADER
         * ========================================================
         */

        Row {
            id: header

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right

                topMargin: 16
                leftMargin: 18
                rightMargin: 18
            }

            height: 42

            spacing: 12


            /*
             * Temporary Crylia logo.
             *
             * Později sem dáme naše SVG.
             */

            Rectangle {
                width: 42
                height: 42

                radius: 10

                color: "#423f59"

                border.width: 1
                border.color: "#5a5e7a"


                Text {
                    anchors.centerIn: parent

                    text: "C"

                    color: "#bb97ee"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 22
                    font.bold: true
                }
            }


            Column {
                anchors.verticalCenter:
                    parent.verticalCenter

                spacing: 1


                Text {
                    text:
                        "Crylia"

                    color: "#e1e3e4"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 15
                    font.bold: true
                }


                Text {
                    text:
                        "APPLICATION LAUNCHER"

                    color: "#7e8294"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }


        /*
         * ========================================================
         * SEARCH
         * ========================================================
         */

        Rectangle {
            id: searchBox

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right

                topMargin: 14
                leftMargin: 18
                rightMargin: 18
            }

            height: 44

            radius: 7

            color: "#333648"

            border.width:
                searchField.activeFocus
                    ? 1
                    : 0

            border.color: "#bb97ee"


            Text {
                anchors {
                    left: parent.left
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 13
                }

                text: "⌕"

                color: "#7e8294"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 17
            }


            TextInput {
                id: searchField

                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 42
                    rightMargin: 12
                }

                height: 30

                verticalAlignment:
                    TextInput.AlignVCenter


                text:
                    root.query


                onTextChanged: {
                    root.query = text

                    applicationList.currentIndex =
                        applicationModel.values.length > 0
                            ? 0
                            : -1
                }


                color: "#e1e3e4"

                selectionColor: "#423f59"
                selectedTextColor: "#e1e3e4"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 12


                Text {
                    anchors.fill: parent

                    verticalAlignment:
                        Text.AlignVCenter

                    visible:
                        searchField.text.length === 0

                    text:
                        "Search applications..."

                    color: "#5a5e7a"

                    font:
                        searchField.font
                }


                Keys.onPressed: event => {
                    if (
                        event.key
                        === Qt.Key_Down
                    ) {
                        if (
                            applicationList.count
                            > 0
                        ) {
                            applicationList.currentIndex =
                                Math.min(
                                    applicationList.count - 1,
                                    applicationList.currentIndex + 1
                                )
                        }

                        event.accepted = true
                    }


                    if (
                        event.key
                        === Qt.Key_Up
                    ) {
                        if (
                            applicationList.count
                            > 0
                        ) {
                            applicationList.currentIndex =
                                Math.max(
                                    0,
                                    applicationList.currentIndex - 1
                                )
                        }

                        event.accepted = true
                    }


                    if (
                        event.key
                        === Qt.Key_Return
                        || event.key
                        === Qt.Key_Enter
                    ) {
                        root.launchCurrent()

                        event.accepted = true
                    }


                    if (
                        event.key
                        === Qt.Key_Escape
                    ) {
                        root.visible = false

                        event.accepted = true
                    }
                }
            }
        }


        /*
         * ========================================================
         * APPLICATION LIST
         * ========================================================
         */

        ListView {
            id: applicationList

            anchors {
                top: searchBox.bottom
                left: parent.left
                right: parent.right
                bottom: footer.top

                topMargin: 12
                leftMargin: 12
                rightMargin: 12
                bottomMargin: 8
            }


            clip: true

            spacing: 3

            currentIndex:
                count > 0
                    ? 0
                    : -1


            model:
                applicationModel


            delegate: Rectangle {
                id: applicationItem

                required property var modelData
                required property int index


                width:
                    ListView.view.width

                height: 48

                radius: 7


                readonly property bool selected:
                    ListView.isCurrentItem


                color:
                    selected
                        ? "#393e53"
                        : applicationMouse
                            .containsMouse
                                ? "#363a4e"
                                : "transparent"


                Behavior on color {
                    ColorAnimation {
                        duration: 80
                    }
                }


                Row {
                    anchors {
                        fill: parent

                        leftMargin: 10
                        rightMargin: 10
                    }

                    spacing: 12


                    IconImage {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        implicitSize: 30


                        source:
                            Quickshell.iconPath(
                                applicationItem
                                    .modelData
                                    .icon
                                || "application-x-executable",

                                "application-x-executable"
                            )
                    }


                    Column {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        width:
                            parent.width - 55

                        spacing: 2


                        Text {
                            width: parent.width

                            text:
                                applicationItem
                                    .modelData
                                    .name

                            elide:
                                Text.ElideRight

                            color: "#e1e3e4"

                            font.family:
                                "JetBrains Mono"

                            font.pixelSize: 11
                            font.bold: true
                        }


                        Text {
                            width: parent.width

                            text:
                                applicationItem
                                    .modelData
                                    .genericName
                                || applicationItem
                                    .modelData
                                    .comment
                                || ""

                            elide:
                                Text.ElideRight

                            color: "#7e8294"

                            font.family:
                                "JetBrains Mono"

                            font.pixelSize: 8
                        }
                    }
                }


                MouseArea {
                    id: applicationMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor


                    onEntered: {
                        applicationList.currentIndex =
                            applicationItem.index
                    }


                    onClicked: {
                        root.launch(
                            applicationItem.modelData
                        )
                    }
                }
            }


            /*
             * Nothing found.
             */

            Text {
                anchors.centerIn: parent

                visible:
                    applicationList.count === 0

                text:
                    "No applications found"

                color: "#5a5e7a"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 11
                font.bold: true
            }
        }


        /*
         * ========================================================
         * FOOTER
         * ========================================================
         */

        Rectangle {
            id: footer

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 18
                rightMargin: 18
                bottomMargin: 12
            }

            height: 32

            radius: 6

            color: "#333648"


            Text {
                anchors.centerIn: parent

                text:
                    "↑ ↓  SELECT    ENTER  OPEN    ESC  CLOSE"

                color: "#5a5e7a"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 8
                font.bold: true
            }
        }
    }


    /*
     * ============================================================
     * OPEN / CLOSE
     * ============================================================
     */

    onVisibleChanged: {
        if (visible) {
            root.query = ""

            searchField.text = ""

            applicationList.currentIndex =
                applicationModel.values.length > 0
                    ? 0
                    : -1

            Qt.callLater(
                function() {
                    searchField
                        .forceActiveFocus()
                }
            )
        }
    }
}

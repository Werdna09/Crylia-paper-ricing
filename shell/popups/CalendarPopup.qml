import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem
    required property var clockService

    property int displayYear: 0
    property int displayMonth: 0

    readonly property date today:
        clockService.date

    readonly property var monthNames: [
        "Leden",
        "Únor",
        "Březen",
        "Duben",
        "Květen",
        "Červen",
        "Červenec",
        "Srpen",
        "Září",
        "Říjen",
        "Listopad",
        "Prosinec"
    ]

    readonly property var monthNamesGenitive: [
        "ledna",
        "února",
        "března",
        "dubna",
        "května",
        "června",
        "července",
        "srpna",
        "září",
        "října",
        "listopadu",
        "prosince"
    ]

    readonly property var dayNames: [
        "neděle",
        "pondělí",
        "úterý",
        "středa",
        "čtvrtek",
        "pátek",
        "sobota"
    ]

    implicitWidth: 360
    implicitHeight: 392

    color: "transparent"
    grabFocus: true


    /*
     * ============================================================
     * ANCHOR
     *
     * Popup chceme vystředit pod clock islandem.
     * ============================================================
     */

    anchor.item: root.anchorItem

    anchor.rect.x:
        Math.round(
            (root.anchorItem.width - root.implicitWidth) / 2
        )

    anchor.rect.y:
        root.anchorItem.height + 7

    anchor.edges:
        Edges.Top | Edges.Left

    anchor.gravity:
        Edges.Bottom | Edges.Right


    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function resetToToday() {
        root.displayYear =
            root.today.getFullYear()

        root.displayMonth =
            root.today.getMonth()
    }


    function previousMonth() {
        const date =
            new Date(
                root.displayYear,
                root.displayMonth - 1,
                1
            )

        root.displayYear =
            date.getFullYear()

        root.displayMonth =
            date.getMonth()
    }


    function nextMonth() {
        const date =
            new Date(
                root.displayYear,
                root.displayMonth + 1,
                1
            )

        root.displayYear =
            date.getFullYear()

        root.displayMonth =
            date.getMonth()
    }


    function showDate(date) {
        root.displayYear =
            date.getFullYear()

        root.displayMonth =
            date.getMonth()
    }


    /*
     * JavaScript:
     *
     * Sunday = 0
     * Monday = 1
     *
     * My chceme:
     *
     * Monday = 0
     * ...
     * Sunday = 6
     */

    function firstDayOffset() {
        const firstDay =
            new Date(
                root.displayYear,
                root.displayMonth,
                1
            ).getDay()

        return (firstDay + 6) % 7
    }


    function dateForCell(index) {
        return new Date(
            root.displayYear,
            root.displayMonth,
            index - root.firstDayOffset() + 1
        )
    }


    function isToday(date) {
        return date.getFullYear()
                === root.today.getFullYear()
            && date.getMonth()
                === root.today.getMonth()
            && date.getDate()
                === root.today.getDate()
    }


    function isCurrentMonth(date) {
        return date.getFullYear()
                === root.displayYear
            && date.getMonth()
                === root.displayMonth
    }


    /*
     * ============================================================
     * WINDOW
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
         * CURRENT TIME
         * ========================================================
         */

        Text {
            id: timeText

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text:
                Qt.formatDateTime(
                    root.clockService.date,
                    "hh:mm"
                )

            color: "#bb97ee"

            font.family: "JetBrains Mono"
            font.pixelSize: 24
            font.bold: true
        }


        Text {
            anchors {
                left: timeText.left
                top: timeText.bottom

                topMargin: 2
            }

            text: {
                const date =
                    root.today

                const day =
                    root.dayNames[
                        date.getDay()
                    ]

                return day.charAt(0).toUpperCase()
                    + day.slice(1)
                    + " "
                    + date.getDate()
                    + ". "
                    + root.monthNamesGenitive[
                        date.getMonth()
                    ]
                    + " "
                    + date.getFullYear()
            }

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        /*
         * TODAY BUTTON
         */

        Rectangle {
            anchors {
                right: parent.right
                verticalCenter:
                    timeText.verticalCenter

                rightMargin: 16
            }

            width: 68
            height: 28

            radius: 5

            color:
                todayMouse.containsMouse
                    ? "#423f59"
                    : "#333648"

            border.width: 1
            border.color: "#423f59"


            Text {
                anchors.centerIn: parent

                text: "DNES"

                color: "#bb97ee"

                font.family: "JetBrains Mono"
                font.pixelSize: 9
                font.bold: true
            }


            MouseArea {
                id: todayMouse

                anchors.fill: parent

                hoverEnabled: true

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.resetToToday()
                }
            }
        }


        /*
         * ========================================================
         * MONTH NAVIGATION
         * ========================================================
         */

        Rectangle {
            id: monthHeader

            anchors {
                top: timeText.bottom
                left: parent.left
                right: parent.right

                topMargin: 32
                leftMargin: 16
                rightMargin: 16
            }

            height: 40

            radius: 6

            color: "#333648"


            /*
             * PREVIOUS
             */

            Rectangle {
                id: previousButton

                anchors {
                    left: parent.left
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 5
                }

                width: 32
                height: 30

                radius: 5

                color:
                    previousMouse.containsMouse
                        ? "#393e53"
                        : "transparent"


                Text {
                    anchors.centerIn: parent

                    text: "◀"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                MouseArea {
                    id: previousMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.previousMonth()
                    }
                }
            }


            /*
             * MONTH
             */

            Text {
                anchors.centerIn: parent

                text:
                    root.monthNames[
                        root.displayMonth
                    ]
                    + " "
                    + root.displayYear

                color: "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
            }


            /*
             * NEXT
             */

            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter

                    rightMargin: 5
                }

                width: 32
                height: 30

                radius: 5

                color:
                    nextMouse.containsMouse
                        ? "#393e53"
                        : "transparent"


                Text {
                    anchors.centerIn: parent

                    text: "▶"

                    color: "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }


                MouseArea {
                    id: nextMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.nextMonth()
                    }
                }
            }
        }


        /*
         * ========================================================
         * WEEKDAY LABELS
         * ========================================================
         */

        Grid {
            id: weekdayGrid

            anchors {
                top: monthHeader.bottom
                horizontalCenter:
                    parent.horizontalCenter

                topMargin: 12
            }

            columns: 7

            columnSpacing: 4


            Repeater {
                model: [
                    "PO",
                    "ÚT",
                    "ST",
                    "ČT",
                    "PÁ",
                    "SO",
                    "NE"
                ]


                delegate: Text {
                    required property string modelData

                    width: 42
                    height: 18

                    text:
                        modelData

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter

                    color: "#5a5e7a"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }


        /*
         * ========================================================
         * DAYS
         * ========================================================
         */

        Grid {
            id: calendarGrid

            anchors {
                top: weekdayGrid.bottom
                horizontalCenter:
                    parent.horizontalCenter

                topMargin: 5
            }

            columns: 7

            columnSpacing: 4
            rowSpacing: 4


            Repeater {
                model: 42


                delegate: Rectangle {
                    id: dayCell

                    required property int index

                    readonly property date cellDate:
                        root.dateForCell(index)

                    readonly property bool today:
                        root.isToday(cellDate)

                    readonly property bool currentMonth:
                        root.isCurrentMonth(cellDate)

                    width: 42
                    height: 34

                    radius: 5


                    color:
                        today
                            ? "#bb97ee"
                            : dayMouse.containsMouse
                                ? "#393e53"
                                : "transparent"


                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }


                    Text {
                        anchors.centerIn: parent

                        text:
                            dayCell.cellDate.getDate()

                        color:
                            dayCell.today
                                ? "#181a1c"
                                : dayCell.currentMonth
                                    ? "#e1e3e4"
                                    : "#5a5e7a"

                        font.family:
                            "JetBrains Mono"

                        font.pixelSize: 10

                        font.bold:
                            dayCell.today
                    }


                    MouseArea {
                        id: dayMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor


                        onClicked: {
                            /*
                             * Kliknutí na šedý den
                             * z vedlejšího měsíce nás
                             * přesune na jeho měsíc.
                             */

                            if (
                                !dayCell.currentMonth
                            ) {
                                root.showDate(
                                    dayCell.cellDate
                                )
                            }
                        }
                    }
                }
            }
        }


        /*
         * ========================================================
         * FOOTER
         * ========================================================
         */

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 16
                rightMargin: 16
                bottomMargin: 12
            }

            height: 30

            radius: 6

            color: "#333648"


            Text {
                anchors.centerIn: parent

                text:
                    "Dnes je "
                    + root.today.getDate()
                    + ". "
                    + root.monthNamesGenitive[
                        root.today.getMonth()
                    ]
                    + " "
                    + root.today.getFullYear()

                color: "#7e8294"

                font.family: "JetBrains Mono"
                font.pixelSize: 9
            }
        }
    }


    /*
     * ============================================================
     * RESET MONTH WHEN OPENED
     * ============================================================
     */

    onVisibleChanged: {
        if (visible) {
            root.resetToToday()
        }
    }


    Component.onCompleted: {
        root.resetToToday()
    }
}

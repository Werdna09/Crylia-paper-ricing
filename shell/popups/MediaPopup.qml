import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem
    required property var mediaService

    readonly property var player:
        mediaService.player

    readonly property bool hasPlayer:
        player !== null

    property real currentPosition: 0

    implicitWidth: 440
    implicitHeight: 300

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function formatTime(seconds) {
        if (
            !isFinite(seconds)
            || seconds < 0
        ) {
            return "--:--"
        }

        const value =
            Math.floor(seconds)

        const hours =
            Math.floor(value / 3600)

        const minutes =
            Math.floor(
                (value % 3600) / 60
            )

        const secs =
            value % 60

        if (hours > 0) {
            return hours
                + ":"
                + String(minutes)
                    .padStart(2, "0")
                + ":"
                + String(secs)
                    .padStart(2, "0")
        }

        return minutes
            + ":"
            + String(secs)
                .padStart(2, "0")
    }


    function refreshPosition() {
        if (
            !root.hasPlayer
            || !root.player.positionSupported
        ) {
            root.currentPosition = 0
            return
        }

        root.currentPosition =
            root.player.position
    }


    function seekFromMouse(mouseX, trackWidth) {
        if (
            !root.hasPlayer
            || !root.player.canSeek
            || !root.player.positionSupported
            || !root.player.lengthSupported
            || root.player.length <= 0
        ) {
            return
        }

        const ratio =
            Math.max(
                0,
                Math.min(
                    1,
                    mouseX / trackWidth
                )
            )

        const newPosition =
            root.player.length * ratio

        root.player.position =
            newPosition

        root.currentPosition =
            newPosition
    }


    /*
     * MPRIS position is intentionally not pushed every second
     * by Quickshell, so we read it while this popup is visible.
     */

    Timer {
        interval: 1000
        repeat: true

        running:
            root.visible
            && root.hasPlayer
            && root.player.positionSupported

        onTriggered: {
            root.refreshPosition()
        }
    }


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
            id: header

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Media"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Text {
            anchors {
                right: parent.right
                verticalCenter:
                    header.verticalCenter

                rightMargin: 16
            }

            text:
                root.hasPlayer
                    ? root.player.identity
                    : "No player"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 9
            font.bold: true
        }


        /*
         * ========================================================
         * ALBUM ART
         * ========================================================
         */

        Rectangle {
            id: artworkContainer

            anchors {
                top: header.bottom
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            width: 110
            height: 110

            radius: 8

            color: "#333648"

            clip: true


            Image {
                anchors.fill: parent

                visible:
                    root.hasPlayer
                    && root.player.trackArtUrl.length > 0

                source:
                    root.hasPlayer
                        ? root.player.trackArtUrl
                        : ""

                fillMode:
                    Image.PreserveAspectCrop

                asynchronous: true
                cache: true
            }


            Text {
                anchors.centerIn: parent

                visible:
                    !root.hasPlayer
                    || root.player.trackArtUrl.length === 0

                text: "♪"

                color: "#bb97ee"

                font.family: "JetBrains Mono"
                font.pixelSize: 38
                font.bold: true
            }
        }


        /*
         * ========================================================
         * TRACK INFORMATION
         * ========================================================
         */

        Column {
            anchors {
                top: artworkContainer.top
                left: artworkContainer.right
                right: parent.right

                leftMargin: 16
                rightMargin: 16
            }

            spacing: 7


            Text {
                width: parent.width

                text:
                    root.hasPlayer
                        ? (
                            root.player.trackTitle.length > 0
                                ? root.player.trackTitle
                                : "Unknown title"
                        )
                        : "Nothing playing"

                elide:
                    Text.ElideRight

                color: "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 14
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.hasPlayer
                        ? (
                            root.player.trackArtist.length > 0
                                ? root.player.trackArtist
                                : "Unknown artist"
                        )
                        : "—"

                elide:
                    Text.ElideRight

                color: "#bb97ee"

                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.hasPlayer
                        ? (
                            root.player.trackAlbum.length > 0
                                ? root.player.trackAlbum
                                : "Unknown album"
                        )
                        : ""

                elide:
                    Text.ElideRight

                color: "#7e8294"

                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }


            /*
             * Player state
             */

            Rectangle {
                width: stateText.width + 16
                height: 24

                radius: 5

                color:
                    root.hasPlayer
                    && root.player.isPlaying
                        ? "#394634"
                        : "#333648"


                Text {
                    id: stateText

                    anchors.centerIn: parent

                    text:
                        !root.hasPlayer
                            ? "NO PLAYER"
                            : root.player.isPlaying
                                ? "PLAYING"
                                : "PAUSED"

                    color:
                        root.hasPlayer
                        && root.player.isPlaying
                            ? "#9ed06c"
                            : "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }


        /*
         * ========================================================
         * PROGRESS
         * ========================================================
         */

        Rectangle {
            id: progressTrack

            anchors {
                top: artworkContainer.bottom
                left: parent.left
                right: parent.right

                topMargin: 20
                leftMargin: 16
                rightMargin: 16
            }

            height: 8

            radius: 4

            color: "#393e53"


            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                width:
                    root.hasPlayer
                    && root.player.lengthSupported
                    && root.player.length > 0
                        ? parent.width
                            * Math.max(
                                0,
                                Math.min(
                                    1,
                                    root.currentPosition
                                    / root.player.length
                                )
                            )
                        : 0

                radius: 4

                color: "#bb97ee"
            }


            Rectangle {
                visible:
                    root.hasPlayer
                    && root.player.lengthSupported
                    && root.player.length > 0

                width: 14
                height: 14

                radius: 7

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    Math.max(
                        0,
                        Math.min(
                            progressTrack.width - width,
                            (
                                progressTrack.width
                                * root.currentPosition
                                / root.player.length
                            )
                            - width / 2
                        )
                    )

                color: "#e1e3e4"
            }


            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter
                }

                height: 28

                enabled:
                    root.hasPlayer
                    && root.player.canSeek
                    && root.player.positionSupported

                cursorShape:
                    enabled
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor


                onPressed: mouse => {
                    root.seekFromMouse(
                        mouse.x,
                        width
                    )
                }


                onPositionChanged: mouse => {
                    if (pressed) {
                        root.seekFromMouse(
                            mouse.x,
                            width
                        )
                    }
                }
            }
        }


        /*
         * TIME
         */

        Text {
            anchors {
                top: progressTrack.bottom
                left: progressTrack.left

                topMargin: 5
            }

            text:
                root.hasPlayer
                && root.player.positionSupported
                    ? root.formatTime(
                        root.currentPosition
                    )
                    : "--:--"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 9
        }


        Text {
            anchors {
                top: progressTrack.bottom
                right: progressTrack.right

                topMargin: 5
            }

            text:
                root.hasPlayer
                && root.player.lengthSupported
                    ? root.formatTime(
                        root.player.length
                    )
                    : "--:--"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 9
        }


        /*
         * ========================================================
         * CONTROLS
         * ========================================================
         */

        Row {
            id: controls

            anchors {
                horizontalCenter:
                    parent.horizontalCenter

                bottom:
                    parent.bottom

                bottomMargin: 15
            }

            spacing: 8


            /*
             * PREVIOUS
             */

            Rectangle {
                width: 56
                height: 36

                radius: 6

                color:
                    root.hasPlayer
                    && root.player.canGoPrevious
                        ? "#333648"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "◀"

                    color:
                        root.hasPlayer
                        && root.player.canGoPrevious
                            ? "#e1e3e4"
                            : "#5a5e7a"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.hasPlayer
                        && root.player.canGoPrevious

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked: {
                        root.mediaService.previous()
                    }
                }
            }


            /*
             * PLAY / PAUSE
             */

            Rectangle {
                width: 92
                height: 36

                radius: 6

                color:
                    root.hasPlayer
                        ? "#bb97ee"
                        : "#333648"


                Text {
                    anchors.centerIn: parent

                    text:
                        !root.hasPlayer
                            ? "—"
                            : root.player.isPlaying
                                ? "PAUSE"
                                : "PLAY"

                    color:
                        root.hasPlayer
                            ? "#181a1c"
                            : "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.hasPlayer
                        && root.player.canTogglePlaying

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked: {
                        root.mediaService.togglePlaying()
                    }
                }
            }


            /*
             * NEXT
             */

            Rectangle {
                width: 56
                height: 36

                radius: 6

                color:
                    root.hasPlayer
                    && root.player.canGoNext
                        ? "#333648"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "▶"

                    color:
                        root.hasPlayer
                        && root.player.canGoNext
                            ? "#e1e3e4"
                            : "#5a5e7a"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.hasPlayer
                        && root.player.canGoNext

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked: {
                        root.mediaService.next()
                    }
                }
            }


            /*
             * OPEN PLAYER
             */

            Rectangle {
                width: 92
                height: 36

                radius: 6

                color:
                    root.hasPlayer
                    && root.player.canRaise
                        ? "#354157"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "PLAYER"

                    color:
                        root.hasPlayer
                        && root.player.canRaise
                            ? "#6dcae8"
                            : "#5a5e7a"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.hasPlayer
                        && root.player.canRaise

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                    onClicked: {
                        root.player.raise()
                    }
                }
            }
        }
    }


    /*
     * Refresh position immediately when opened.
     */

    onVisibleChanged: {
        if (visible) {
            root.refreshPosition()
        }
    }
}

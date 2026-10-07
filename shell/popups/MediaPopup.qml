import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property Item anchorItem
    required property var mediaService


    /*
     * ============================================================
     * PLAYER
     * ============================================================
     */

    readonly property var player:
        mediaService.player


    readonly property bool hasPlayer:
        player !== null
        && player !== undefined


    /*
     * ============================================================
     * SAFE METADATA
     *
     * MPRIS player se může za běhu změnit nebo úplně zmizet.
     * Do UI proto neposíláme přímé player.* bindingy.
     * ============================================================
     */

    readonly property string safeTitle: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackTitle || ""
    }


    readonly property string safeArtist: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackArtist || ""
    }


    readonly property string safeAlbum: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackAlbum || ""
    }


    readonly property string safeArtUrl: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.trackArtUrl || ""
    }


    readonly property string safeIdentity: {
        const p = root.player

        if (p === null || p === undefined) {
            return ""
        }

        return p.identity || ""
    }


    /*
     * ============================================================
     * SAFE PLAYER STATE
     * ============================================================
     */

    readonly property bool playing: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.isPlaying
    }


    readonly property bool positionSupported: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.positionSupported
    }


    readonly property bool lengthSupported: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.lengthSupported
    }


    readonly property bool canSeek: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canSeek
    }


    readonly property bool canGoPrevious: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canGoPrevious
    }


    readonly property bool canGoNext: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canGoNext
    }


    readonly property bool canTogglePlaying: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canTogglePlaying
    }


    readonly property bool canRaise: {
        const p = root.player

        return p !== null
            && p !== undefined
            && p.canRaise
    }


    readonly property real trackLength: {
        const p = root.player

        if (
            p === null
            || p === undefined
            || !p.lengthSupported
        ) {
            return 0
        }

        const value = Number(p.length)

        if (
            !isFinite(value)
            || value <= 0
        ) {
            return 0
        }

        return value
    }


    property real currentPosition: 0


    /*
     * ============================================================
     * WINDOW
     * ============================================================
     */

    implicitWidth: 440
    implicitHeight: 300

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem

    anchor.edges:
        Edges.Bottom | Edges.Right

    anchor.gravity:
        Edges.Bottom | Edges.Left

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
            Math.floor(
                value / 3600
            )

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
        const p =
            root.player

        if (
            p === null
            || p === undefined
            || !p.positionSupported
        ) {
            root.currentPosition = 0

            return
        }


        const value =
            Number(p.position)


        root.currentPosition =
            isFinite(value)
            && value >= 0
                ? value
                : 0
    }


    function seekFromMouse(
        mouseX,
        trackWidth
    ) {
        const p =
            root.player


        if (
            p === null
            || p === undefined
            || !p.canSeek
            || !p.positionSupported
            || !p.lengthSupported
        ) {
            return
        }


        const length =
            Number(p.length)


        if (
            !isFinite(length)
            || length <= 0
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
            length * ratio


        p.position =
            newPosition


        root.currentPosition =
            newPosition
    }


    function raisePlayer() {
        const p =
            root.player

        if (
            p === null
            || p === undefined
            || !p.canRaise
        ) {
            return
        }

        p.raise()
    }


    /*
     * ============================================================
     * POSITION TIMER
     *
     * MPRIS position se záměrně neposílá jako nový údaj
     * několikrát za sekundu. Čteme ji pouze při otevřeném popupu.
     * ============================================================
     */

    Timer {
        interval: 1000
        repeat: true

        running:
            root.visible
            && root.positionSupported


        onTriggered: {
            root.refreshPosition()
        }
    }


    /*
     * ============================================================
     * POPUP CONTENT
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
            id: header

            anchors {
                top: parent.top
                left: parent.left

                topMargin: 15
                leftMargin: 16
            }

            text: "Media"

            color: "#e1e3e4"

            font.family:
                "JetBrains Mono"

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
                root.safeIdentity !== ""
                    ? root.safeIdentity
                    : "No player"

            color: "#7e8294"

            font.family:
                "JetBrains Mono"

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
                    root.safeArtUrl !== ""

                source:
                    root.safeArtUrl

                fillMode:
                    Image.PreserveAspectCrop

                asynchronous: true
                cache: true
            }


            Text {
                anchors.centerIn: parent

                visible:
                    root.safeArtUrl === ""

                text: "♪"

                color: "#bb97ee"

                font.family:
                    "JetBrains Mono"

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
                    root.safeTitle !== ""
                        ? root.safeTitle
                        : "Unknown title"

                elide:
                    Text.ElideRight

                color: "#e1e3e4"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 14
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.safeArtist !== ""
                        ? root.safeArtist
                        : "Unknown artist"

                elide:
                    Text.ElideRight

                color: "#bb97ee"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 11
                font.bold: true
            }


            Text {
                width: parent.width

                text:
                    root.safeAlbum !== ""
                        ? root.safeAlbum
                        : "Unknown album"

                elide:
                    Text.ElideRight

                color: "#7e8294"

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 10
            }


            /*
             * PLAYER STATE
             */

            Rectangle {
                width:
                    stateText.width + 16

                height: 24

                radius: 5

                color:
                    root.playing
                        ? "#394634"
                        : "#333648"


                Text {
                    id: stateText

                    anchors.centerIn: parent

                    text:
                        !root.hasPlayer
                            ? "NO PLAYER"
                            : root.playing
                                ? "PLAYING"
                                : "PAUSED"

                    color:
                        root.playing
                            ? "#9ed06c"
                            : "#7e8294"

                    font.family:
                        "JetBrains Mono"

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


            /*
             * PROGRESS FILL
             */

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                width:
                    root.trackLength > 0
                        ? parent.width
                            * Math.max(
                                0,
                                Math.min(
                                    1,
                                    root.currentPosition
                                    / root.trackLength
                                )
                            )
                        : 0

                radius: 4

                color: "#bb97ee"
            }


            /*
             * PROGRESS KNOB
             */

            Rectangle {
                visible:
                    root.trackLength > 0

                width: 14
                height: 14

                radius: 7

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    root.trackLength > 0
                        ? Math.max(
                            0,
                            Math.min(
                                progressTrack.width - width,
                                (
                                    progressTrack.width
                                    * root.currentPosition
                                    / root.trackLength
                                )
                                - width / 2
                            )
                        )
                        : 0

                color: "#e1e3e4"
            }


            /*
             * SEEK INPUT
             */

            MouseArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter
                }

                height: 28

                enabled:
                    root.canSeek
                    && root.positionSupported
                    && root.trackLength > 0

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
         * ========================================================
         * TIME
         * ========================================================
         */

        Text {
            anchors {
                top: progressTrack.bottom
                left: progressTrack.left

                topMargin: 5
            }

            text:
                root.positionSupported
                    ? root.formatTime(
                        root.currentPosition
                    )
                    : "--:--"

            color: "#7e8294"

            font.family:
                "JetBrains Mono"

            font.pixelSize: 9
        }


        Text {
            anchors {
                top: progressTrack.bottom
                right: progressTrack.right

                topMargin: 5
            }

            text:
                root.trackLength > 0
                    ? root.formatTime(
                        root.trackLength
                    )
                    : "--:--"

            color: "#7e8294"

            font.family:
                "JetBrains Mono"

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
                    root.canGoPrevious
                        ? "#333648"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "◀"

                    color:
                        root.canGoPrevious
                            ? "#e1e3e4"
                            : "#5a5e7a"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.canGoPrevious

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
                            : root.playing
                                ? "PAUSE"
                                : "PLAY"

                    color:
                        root.hasPlayer
                            ? "#181a1c"
                            : "#7e8294"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 10
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.canTogglePlaying

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
                    root.canGoNext
                        ? "#333648"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "▶"

                    color:
                        root.canGoNext
                            ? "#e1e3e4"
                            : "#5a5e7a"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 13
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.canGoNext

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
                    root.canRaise
                        ? "#354157"
                        : "#252630"


                Text {
                    anchors.centerIn: parent

                    text: "PLAYER"

                    color:
                        root.canRaise
                            ? "#6dcae8"
                            : "#5a5e7a"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 9
                    font.bold: true
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        root.canRaise

                    cursorShape:
                        enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor


                    onClicked: {
                        root.raisePlayer()
                    }
                }
            }
        }
    }


    /*
     * ============================================================
     * PLAYER CHANGES
     * ============================================================
     */

    onPlayerChanged: {
        root.refreshPosition()
    }


    /*
     * ============================================================
     * POPUP OPEN
     * ============================================================
     */

    onVisibleChanged: {
        if (visible) {
            root.refreshPosition()
        }
    }
}

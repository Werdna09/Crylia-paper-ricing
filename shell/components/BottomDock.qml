import QtQuick
import Quickshell
import Quickshell.Widgets


Scope {
    id: root

    required property var windowService


    /*
     * ============================================================
     * PINNED APPLICATIONS
     * ============================================================
     */

    property var pinnedApps: [
        {
            key: "firefox",

            matchKeys: [
                "firefox"
            ],

            lookup: "firefox",

            fallbackIcon:
                "firefox",

            command: [
                "firefox"
            ]
        },

        {
            key: "org.kde.dolphin",

            matchKeys: [
                "org.kde.dolphin",
                "dolphin"
            ],

            lookup:
                "org.kde.dolphin",

            fallbackIcon:
                "system-file-manager",

            command: [
                "dolphin"
            ]
        },

        {
            key: "alacritty",

            matchKeys: [
                "alacritty"
            ],

            lookup:
                "Alacritty",

            fallbackIcon:
                "utilities-terminal",

            command: [
                "alacritty"
            ]
        }
    ]


    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function normalizeKey(value) {
        let result =
            String(value || "").trim()


        const slash =
            result.lastIndexOf("/")


        if (slash >= 0) {
            result =
                result.substring(
                    slash + 1
                )
        }


        if (
            result.toLowerCase()
                .endsWith(".desktop")
        ) {
            result =
                result.substring(
                    0,
                    result.length - 8
                )
        }


        return result.toLowerCase()
    }


    function pinnedMatches(
        pinned,
        running
    ) {
        if (
            pinned === null
            || running === null
        ) {
            return false
        }


        const key =
            root.normalizeKey(
                running.key
            )


        const matches =
            pinned.matchKeys || []


        for (
            let i = 0;
            i < matches.length;
            i++
        ) {
            if (
                root.normalizeKey(
                    matches[i]
                ) === key
            ) {
                return true
            }
        }


        return false
    }


    /*
     * ============================================================
     * DESKTOP ENTRY
     * ============================================================
     */

    function desktopEntryFor(app) {
        if (
            app === null
            || app === undefined
        ) {
            return null
        }


        const candidates = []


        function addCandidate(value) {
            const raw =
                String(value || "").trim()


            if (raw === "") {
                return
            }


            if (
                candidates.indexOf(raw)
                === -1
            ) {
                candidates.push(raw)
            }


            /*
             * Zkusíme variantu s .desktop
             * i bez ní.
             */

            if (
                !raw.toLowerCase()
                    .endsWith(".desktop")
            ) {
                const withDesktop =
                    raw + ".desktop"

                if (
                    candidates.indexOf(
                        withDesktop
                    ) === -1
                ) {
                    candidates.push(
                        withDesktop
                    )
                }
            }
        }


        addCandidate(
            app.desktopFile
        )

        addCandidate(
            app.lookup
        )

        addCandidate(
            app.resourceClass
        )

        addCandidate(
            app.key
        )


        /*
         * Nejdřív exact DesktopEntry ID.
         */

        for (
            let i = 0;
            i < candidates.length;
            i++
        ) {
            const entry =
                DesktopEntries.byId(
                    candidates[i]
                )


            if (entry !== null) {
                return entry
            }
        }


        /*
         * Pak heuristika.
         */

        const heuristicCandidates = [
            app.desktopFile,
            app.lookup,
            app.resourceClass,
            app.key,
            app.caption
        ]


        for (
            let i = 0;
            i < heuristicCandidates.length;
            i++
        ) {
            const value =
                String(
                    heuristicCandidates[i]
                    || ""
                )


            if (value === "") {
                continue
            }


            const entry =
                DesktopEntries
                    .heuristicLookup(
                        value
                    )


            if (entry !== null) {
                return entry
            }
        }


        return null
    }


    /*
     * ============================================================
     * COMBINE PINNED + RUNNING APPLICATIONS
     * ============================================================
     */

    function buildDockApps() {
        const runningApps =
            root.windowService.applications
            || []

        const result = []

        const usedRunningKeys = {}


        /*
         * ========================================================
         * PINNED
         * ========================================================
         */

        for (
            let p = 0;
            p < root.pinnedApps.length;
            p++
        ) {
            const pinned =
                root.pinnedApps[p]

            let running =
                null


            for (
                let r = 0;
                r < runningApps.length;
                r++
            ) {
                if (
                    root.pinnedMatches(
                        pinned,
                        runningApps[r]
                    )
                ) {
                    running =
                        runningApps[r]

                    break
                }
            }


            if (running !== null) {
                usedRunningKeys[
                    running.key
                ] = true


                result.push({
                    key:
                        pinned.key,

                    pinned:
                        true,

                    running:
                        true,

                    active:
                        running.active,

                    minimized:
                        running.minimized,

                    windowCount:
                        running.windowCount,

                    activeWindowId:
                        running.activeWindowId,

                    representativeId:
                        running.representativeId,

                    desktopFile:
                        running.desktopFile,

                    resourceClass:
                        running.resourceClass,

                    caption:
                        running.caption,

                    lookup:
                        pinned.lookup,

                    fallbackIcon:
                        pinned.fallbackIcon,

                    command:
                        pinned.command,

                    signature:
                        pinned.key
                        + "|1|"
                        + running.active
                        + "|"
                        + running.minimized
                        + "|"
                        + running.windowCount
                        + "|"
                        + running.activeWindowId
                        + "|"
                        + running.representativeId
                })
            } else {
                result.push({
                    key:
                        pinned.key,

                    pinned:
                        true,

                    running:
                        false,

                    active:
                        false,

                    minimized:
                        false,

                    windowCount:
                        0,

                    activeWindowId:
                        "",

                    representativeId:
                        "",

                    desktopFile:
                        pinned.lookup,

                    resourceClass:
                        "",

                    caption:
                        "",

                    lookup:
                        pinned.lookup,

                    fallbackIcon:
                        pinned.fallbackIcon,

                    command:
                        pinned.command,

                    signature:
                        pinned.key
                        + "|0"
                })
            }
        }


        /*
         * ========================================================
         * NON-PINNED RUNNING APPS
         * ========================================================
         */

        for (
            let i = 0;
            i < runningApps.length;
            i++
        ) {
            const running =
                runningApps[i]


            if (
                usedRunningKeys[
                    running.key
                ]
            ) {
                continue
            }


            result.push({
                key:
                    running.key,

                pinned:
                    false,

                running:
                    true,

                active:
                    running.active,

                minimized:
                    running.minimized,

                windowCount:
                    running.windowCount,

                activeWindowId:
                    running.activeWindowId,

                representativeId:
                    running.representativeId,

                desktopFile:
                    running.desktopFile,

                resourceClass:
                    running.resourceClass,

                caption:
                    running.caption,

                lookup:
                    running.desktopFile,

                fallbackIcon:
                    "application-x-executable",

                command:
                    [],

                signature:
                    running.key
                    + "|1|"
                    + running.active
                    + "|"
                    + running.minimized
                    + "|"
                    + running.windowCount
                    + "|"
                    + running.activeWindowId
                    + "|"
                    + running.representativeId
            })
        }


        return result
    }


    /*
     * ============================================================
     * LAUNCH
     * ============================================================
     */

    function launchApp(
        app,
        desktopEntry
    ) {
        if (desktopEntry !== null) {
            desktopEntry.execute()

            root.windowService
                .refreshSoon(650)

            return
        }


        if (
            app.command !== undefined
            && app.command !== null
            && app.command.length > 0
        ) {
            Quickshell.execDetached(
                app.command
            )


            root.windowService
                .refreshSoon(650)
        }
    }


    /*
     * ============================================================
     * ONE DOCK PER SCREEN
     * ============================================================
     */

    Variants {
        model: Quickshell.screens


        PanelWindow {
            id: dockWindow

            required property var modelData

            screen: modelData


            /*
             * ====================================================
             * STATE
             * ====================================================
             */

            property bool shown: false


            /*
             * ====================================================
             * WINDOW
             * ====================================================
             */

            anchors {
                left: true
                right: true
                bottom: true
            }

            implicitHeight: 80

            color: "transparent"

            exclusionMode:
                ExclusionMode.Ignore

            aboveWindows: true
            focusable: false


            /*
             * ====================================================
             * INPUT MASK
             * ====================================================
             */

            mask: Region {
                x: dockSurface.x
                y: dockSurface.y

                width:
                    dockSurface.width

                height:
                    dockSurface.height

                radius: 11


                Region {
                    x: 0

                    y:
                        dockWindow.implicitHeight
                        - edgeTrigger.height

                    width:
                        dockWindow.width

                    height:
                        edgeTrigger.height
                }
            }


            /*
             * ====================================================
             * HELPERS
             * ====================================================
             */

            function showDock() {
                hideTimer.stop()

                dockWindow.shown = true
            }


            function scheduleHide() {
                hideTimer.restart()
            }


            /*
             * ====================================================
             * AUTO-HIDE
             * ====================================================
             */

            Timer {
                id: hideTimer

                interval: 450

                repeat: false


                onTriggered: {
                    if (
                        !edgeHover.hovered
                        && !dockHover.hovered
                    ) {
                        dockWindow.shown = false
                    }
                }
            }


            /*
             * ====================================================
             * BOTTOM EDGE TRIGGER
             * ====================================================
             */

            Rectangle {
                id: edgeTrigger

                x: 0

                y:
                    parent.height
                    - height

                width: parent.width
                height: 3

                color: "transparent"


                HoverHandler {
                    id: edgeHover


                    onHoveredChanged: {
                        if (hovered) {
                            dockWindow.showDock()
                        } else {
                            dockWindow.scheduleHide()
                        }
                    }
                }
            }


            /*
             * ====================================================
             * DOCK SURFACE
             * ====================================================
             */

            Rectangle {
                id: dockSurface


                width:
                    dockRow.width + 18

                height: 64


                x:
                    Math.round(
                        (
                            parent.width
                            - width
                        ) / 2
                    )


                y:
                    dockWindow.shown
                        ? 8
                        : dockWindow
                            .implicitHeight
                            + 6


                radius: 11

                color: "#2b2d3a"

                border.width: 1
                border.color: "#3f445b"


                Behavior on y {
                    NumberAnimation {
                        duration: 180

                        easing.type:
                            Easing.OutCubic
                    }
                }


                Behavior on width {
                    NumberAnimation {
                        duration: 160

                        easing.type:
                            Easing.OutCubic
                    }
                }


                HoverHandler {
                    id: dockHover


                    onHoveredChanged: {
                        if (hovered) {
                            dockWindow.showDock()
                        } else {
                            dockWindow.scheduleHide()
                        }
                    }
                }


                /*
                 * =================================================
                 * APPLICATION MODEL
                 * =================================================
                 */

                ScriptModel {
                    id: dockModel

                    values:
                        root.buildDockApps()

                    /*
                     * Signature se změní pouze tehdy,
                     * když se změní stav aplikace.
                     */

                    objectProp:
                        "signature"
                }


                /*
                 * =================================================
                 * APPLICATIONS
                 * =================================================
                 */

                Row {
                    id: dockRow

                    anchors.centerIn: parent

                    spacing: 6


                    Repeater {
                        model: dockModel


                        delegate: Rectangle {
                            id: appButton

                            required property var modelData


                            readonly property var desktopEntry:
                                root.desktopEntryFor(
                                    modelData
                                )


                            readonly property string iconName:
                                desktopEntry !== null
                                && desktopEntry.icon
                                    ? desktopEntry.icon
                                    : modelData.fallbackIcon


                            width: 54
                            height: 54

                            radius: 8


                            /*
                             * =====================================
                             * BACKGROUND
                             * =====================================
                             */

                            color:
                                modelData.active
                                    ? "#393e53"
                                    : appMouse.containsMouse
                                        ? "#363a4e"
                                        : "transparent"


                            Behavior on color {
                                ColorAnimation {
                                    duration: 100
                                }
                            }


                            /*
                             * =====================================
                             * ICON
                             * =====================================
                             */

                            IconImage {
                                anchors {
                                    horizontalCenter:
                                        parent.horizontalCenter

                                    verticalCenter:
                                        parent.verticalCenter

                                    verticalCenterOffset:
                                        -2
                                }


                                implicitSize:
                                    appMouse.containsMouse
                                        ? 40
                                        : modelData.active
                                            ? 39
                                            : 36


                                source:
                                    Quickshell.iconPath(
                                        appButton.iconName,
                                        "application-x-executable"
                                    )


                                opacity:
                                    modelData.running
                                    && modelData.minimized
                                        ? 0.60
                                        : 1.0


                                Behavior on implicitSize {
                                    NumberAnimation {
                                        duration: 110

                                        easing.type:
                                            Easing.OutCubic
                                    }
                                }


                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }
                                }
                            }


                            /*
                             * =====================================
                             * WINDOW COUNT
                             * =====================================
                             */

                            Rectangle {
                                visible:
                                    modelData.windowCount > 1

                                anchors {
                                    top: parent.top
                                    right: parent.right

                                    topMargin: 3
                                    rightMargin: 3
                                }

                                width: 18
                                height: 18

                                radius: 9

                                color: "#423f59"


                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        modelData.windowCount

                                    color: "#bb97ee"

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }


                            /*
                             * =====================================
                             * RUNNING INDICATOR
                             * =====================================
                             */

                            Rectangle {
                                anchors {
                                    horizontalCenter:
                                        parent.horizontalCenter

                                    bottom:
                                        parent.bottom

                                    bottomMargin: 2
                                }


                                width:
                                    modelData.active
                                        ? 24
                                        : modelData.running
                                            ? 12
                                            : 0


                                height:
                                    modelData.active
                                        ? 3
                                        : 2


                                radius: 2


                                color:
                                    modelData.active
                                        ? "#6dcae8"
                                        : "#bb97ee"


                                Behavior on width {
                                    NumberAnimation {
                                        duration: 140

                                        easing.type:
                                            Easing.OutCubic
                                    }
                                }


                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }
                            }


                            /*
                             * =====================================
                             * INPUT
                             *
                             * Left:
                             *
                             * neběží  -> spustit
                             * běží    -> aktivovat
                             * aktivní -> minimalizovat
                             *
                             * Middle:
                             *
                             * nová instance
                             * =====================================
                             */

                            MouseArea {
                                id: appMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.MiddleButton

                                cursorShape:
                                    Qt.PointingHandCursor


                                onClicked: mouse => {
                                    /*
                                     * Middle click:
                                     * new instance.
                                     */

                                    if (
                                        mouse.button
                                        === Qt.MiddleButton
                                    ) {
                                        root.launchApp(
                                            modelData,
                                            appButton.desktopEntry
                                        )

                                        return
                                    }


                                    /*
                                     * Not running:
                                     * launch.
                                     */

                                    if (
                                        !modelData.running
                                    ) {
                                        root.launchApp(
                                            modelData,
                                            appButton.desktopEntry
                                        )

                                        return
                                    }


                                    /*
                                     * Active:
                                     * minimize active window.
                                     */

                                    if (
                                        modelData.active
                                        && modelData.activeWindowId
                                            !== ""
                                    ) {
                                        root.windowService
                                            .minimize(
                                                modelData
                                                    .activeWindowId
                                            )

                                        return
                                    }


                                    /*
                                     * Running but inactive:
                                     * activate representative window.
                                     */

                                    if (
                                        modelData.representativeId
                                        !== ""
                                    ) {
                                        root.windowService
                                            .activate(
                                                modelData
                                                    .representativeId
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

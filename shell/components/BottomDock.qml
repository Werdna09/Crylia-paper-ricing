import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.popups

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
            matchKeys: ["firefox"],
            lookup: "firefox",
            fallbackIcon: "firefox",
            command: ["firefox"]
        },
        {
            key: "org.kde.dolphin",
            matchKeys: ["org.kde.dolphin", "dolphin"],
            lookup: "org.kde.dolphin",
            fallbackIcon: "system-file-manager",
            command: ["dolphin"]
        },
        {
            key: "alacritty",
            matchKeys: ["alacritty"],
            lookup: "Alacritty",
            fallbackIcon: "utilities-terminal",
            command: ["alacritty"]
        }
    ]

    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function normalizeKey(value) {
        let result = String(value || "").trim()
        const slash = result.lastIndexOf("/")

        if (slash >= 0) {
            result = result.substring(slash + 1)
        }

        if (result.toLowerCase().endsWith(".desktop")) {
            result = result.substring(0, result.length - 8)
        }

        return result.toLowerCase()
    }

    function pinnedMatches(pinned, running) {
        if (pinned === null || running === null) {
            return false
        }

        const key = root.normalizeKey(running.key)
        const matches = pinned.matchKeys || []

        for (let i = 0; i < matches.length; i++) {
            if (root.normalizeKey(matches[i]) === key) {
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
        if (app === null || app === undefined) {
            return null
        }

        const candidates = []

        function addCandidate(value) {
            const raw = String(value || "").trim()

            if (raw === "") {
                return
            }

            if (candidates.indexOf(raw) === -1) {
                candidates.push(raw)
            }

            if (!raw.toLowerCase().endsWith(".desktop")) {
                const withDesktop = raw + ".desktop"

                if (candidates.indexOf(withDesktop) === -1) {
                    candidates.push(withDesktop)
                }
            }
        }

        addCandidate(app.desktopFile)
        addCandidate(app.lookup)
        addCandidate(app.resourceClass)
        addCandidate(app.key)

        for (let i = 0; i < candidates.length; i++) {
            const entry = DesktopEntries.byId(candidates[i])

            if (entry !== null) {
                return entry
            }
        }

        const heuristicCandidates = [
            app.desktopFile,
            app.lookup,
            app.resourceClass,
            app.key,
            app.caption
        ]

        for (let i = 0; i < heuristicCandidates.length; i++) {
            const value = String(heuristicCandidates[i] || "")

            if (value === "") {
                continue
            }

            const entry = DesktopEntries.heuristicLookup(value)

            if (entry !== null) {
                return entry
            }
        }

        return null
    }

    function displayNameFor(app, desktopEntry) {
        if (desktopEntry !== null && desktopEntry.name) {
            return desktopEntry.name
        }

        if (app.resourceClass !== undefined && app.resourceClass !== "") {
            return app.resourceClass
        }

        if (app.key !== undefined && app.key !== "") {
            return app.key
        }

        return "Application"
    }

    /*
     * ============================================================
     * COMBINE PINNED + RUNNING APPLICATIONS
     * ============================================================
     */

    function buildDockApps() {
        const runningApps = root.windowService.applications || []
        const result = []
        const usedRunningKeys = {}

        for (let p = 0; p < root.pinnedApps.length; p++) {
            const pinned = root.pinnedApps[p]
            let running = null

            for (let r = 0; r < runningApps.length; r++) {
                if (root.pinnedMatches(pinned, runningApps[r])) {
                    running = runningApps[r]
                    break
                }
            }

            if (running !== null) {
                usedRunningKeys[running.key] = true

                result.push({
                    key: pinned.key,
                    pinned: true,
                    running: true,
                    active: running.active,
                    minimized: running.minimized,
                    windowCount: running.windowCount,
                    activeWindowId: running.activeWindowId,
                    representativeId: running.representativeId,
                    desktopFile: running.desktopFile,
                    resourceClass: running.resourceClass,
                    caption: running.caption,
                    lookup: pinned.lookup,
                    fallbackIcon: pinned.fallbackIcon,
                    command: pinned.command,
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
                    key: pinned.key,
                    pinned: true,
                    running: false,
                    active: false,
                    minimized: false,
                    windowCount: 0,
                    activeWindowId: "",
                    representativeId: "",
                    desktopFile: pinned.lookup,
                    resourceClass: "",
                    caption: "",
                    lookup: pinned.lookup,
                    fallbackIcon: pinned.fallbackIcon,
                    command: pinned.command,
                    signature: pinned.key + "|0"
                })
            }
        }

        for (let i = 0; i < runningApps.length; i++) {
            const running = runningApps[i]

            if (usedRunningKeys[running.key]) {
                continue
            }

            result.push({
                key: running.key,
                pinned: false,
                running: true,
                active: running.active,
                minimized: running.minimized,
                windowCount: running.windowCount,
                activeWindowId: running.activeWindowId,
                representativeId: running.representativeId,
                desktopFile: running.desktopFile,
                resourceClass: running.resourceClass,
                caption: running.caption,
                lookup: running.desktopFile,
                fallbackIcon: "application-x-executable",
                command: [],
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
     * ACTIONS
     * ============================================================
     */

    function launchApp(app, desktopEntry) {
        if (desktopEntry !== null) {
            desktopEntry.execute()
            root.windowService.refreshSoon(650)
            return
        }

        if (
            app.command !== undefined
            && app.command !== null
            && app.command.length > 0
        ) {
            Quickshell.execDetached(app.command)
            root.windowService.refreshSoon(650)
        }
    }

    function closeWindow(windowId) {
        const id = String(windowId || "")

        if (id === "") {
            return
        }

        Quickshell.execDetached([
            "kdotool",
            "windowclose",
            id
        ])

        root.windowService.refreshSoon(350)
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

            property bool shown: false
            property bool contextMenuOpen: false
            property bool launcherOpen: false

            anchors {
                left: true
                right: true
                bottom: true
            }

            implicitHeight: 72

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            aboveWindows: true
            focusable: false

            mask: Region {
                x: dockSurface.x
                y: dockSurface.y
                width: dockSurface.width
                height: dockSurface.height
                radius: 10

                Region {
                    x: 0
                    y: dockWindow.implicitHeight - edgeTrigger.height
                    width: dockWindow.width
                    height: edgeTrigger.height
                }
            }

            function showDock() {
                hideTimer.stop()
                dockWindow.shown = true
            }

            function scheduleHide() {
                hideTimer.restart()
            }

            Timer {
                id: hideTimer

                interval: 450
                repeat: false

                onTriggered: {
                    if (
                        !edgeHover.hovered
                        && !dockHover.hovered
                        && !dockWindow.contextMenuOpen
                        && !dockWindow.launcherOpen
                    ) {
                        dockWindow.shown = false
                    }
                }
            }

            Rectangle {
                id: edgeTrigger

                x: 0
                y: parent.height - height
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

            Rectangle {
                id: dockSurface

                width: dockRow.width + 8
                height: 52

                x: Math.round((parent.width - width) / 2)

                y: dockWindow.shown
                    ? 6
                    : dockWindow.implicitHeight + 6

                radius: 10
                color: "#2b2d3a"
                border.width: 1
                border.color: "#3f445b"

                Behavior on y {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
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

                ScriptModel {
                    id: dockModel
                    values: root.buildDockApps()
                    objectProp: "signature"
                }

                Row {
                    id: dockRow

                    anchors.centerIn: parent
                    spacing: 2

                    /*
                     * ============================================
                     * CRYLIA LAUNCHER
                     * ============================================
                     */

                    Rectangle {
                        id: launcherButton

                        width: 42
                        height: 46
                        radius: 7

                        color:
                            launcherPopup.visible
                            ? "#393e53"
                            : launcherMouse.containsMouse
                            ? "#363a4e"
                            : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        Rectangle {
                            anchors.centerIn: parent

                            width: 32
                            height: 32
                            radius: 8

                            color: "#423f59"
                            border.width: 1
                            border.color: "#5a5e7a"

                            Text {
                                anchors.centerIn: parent
                                text: "C"
                                color: "#bb97ee"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 18
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: launcherMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                launcherPopup.visible = !launcherPopup.visible
                            }
                        }

                        CryliaLauncher {
                            id: launcherPopup

                            anchorItem: launcherButton
                            visible: false

                            onVisibleChanged: {
                                dockWindow.launcherOpen = visible

                                if (visible) {
                                    dockWindow.showDock()
                                } else {
                                    dockWindow.scheduleHide()
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 30
                        color: "#3f445b"
                    }

                    /*
                     * ============================================
                     * APPLICATIONS
                     * ============================================
                     */

                    Repeater {
                        model: dockModel

                        delegate: Rectangle {
                            id: appButton

                            required property var modelData

                            readonly property var desktopEntry:
                                root.desktopEntryFor(modelData)

                            readonly property string appName:
                                root.displayNameFor(modelData, desktopEntry)

                            readonly property string iconName:
                                desktopEntry !== null && desktopEntry.icon
                                ? desktopEntry.icon
                                : modelData.fallbackIcon

                            readonly property string targetWindowId:
                                modelData.active && modelData.activeWindowId !== ""
                                ? modelData.activeWindowId
                                : modelData.representativeId

                            readonly property bool isRunning:
                                modelData.running === true

                            readonly property bool isActive:
                                modelData.active === true

                            readonly property bool isMinimized:
                                modelData.minimized === true

                            readonly property int windowCount:
                                Math.max(0, Number(modelData.windowCount || 0))

                            readonly property int indicatorCount:
                                Math.min(windowCount, 4)

                            readonly property string statusText:
                                !isRunning
                                ? "PINNED"
                                : (
                                    isActive
                                    ? "ACTIVE"
                                    : "RUNNING"
                                )
                                + " · "
                                + windowCount
                                + (
                                    windowCount === 1
                                    ? " WINDOW"
                                    : " WINDOWS"
                                )

                            /*
                             * Žádný trvalý ostrůvek.
                             * Pozadí se ukáže jen při hoveru nebo menu.
                             */

                            width: 42
                            height: 46
                            radius: 7

                            color:
                                contextMenu.visible
                                ? "#393e53"
                                : appMouse.containsMouse
                                ? "#363a4e"
                                : "transparent"

                            border.width: 0

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            IconImage {
                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    verticalCenter: parent.verticalCenter
                                    verticalCenterOffset: -2
                                }

                                implicitSize: 35

                                source:
                                    Quickshell.iconPath(
                                        appButton.iconName,
                                        "application-x-executable"
                                    )

                                opacity:
                                    appButton.isRunning
                                    && appButton.isMinimized
                                    ? 0.60
                                    : 1.0

                                Behavior on opacity {
                                    NumberAnimation { duration: 120 }
                                }
                            }

                            /*
                             * ========================================
                             * WINDOW INDICATORS
                             * ========================================
                             *
                             * 1 window  -> 1 proužek
                             * 2 windows -> 2 proužky
                             * 3 windows -> 3 proužky
                             * 4+        -> 4 proužky
                             *
                             * Délky zůstávají stejné jako předtím,
                             * jen jsou proužky silnější.
                             */

                            Item {
                                id: indicatorArea

                                visible:
                                    appButton.isRunning
                                    && appButton.indicatorCount > 0

                                anchors {
                                    horizontalCenter: parent.horizontalCenter
                                    bottom: parent.bottom
                                    bottomMargin: 1
                                }

                                width: 34
                                height: 6

                                Row {
                                    anchors.centerIn: parent

                                    spacing:
                                        appButton.indicatorCount >= 4
                                        ? 2
                                        : 3

                                    Repeater {
                                        model: appButton.indicatorCount

                                        Rectangle {
                                            width:
                                                appButton.indicatorCount === 1
                                                ? (
                                                    appButton.isActive
                                                    ? 24
                                                    : 18
                                                )
                                                : appButton.indicatorCount === 2
                                                ? 10
                                                : appButton.indicatorCount === 3
                                                ? 7
                                                : 6

                                            height:
                                                appButton.isActive
                                                ? 4
                                                : 3

                                            radius: height / 2

                                            color:
                                                appButton.isActive
                                                ? "#6dcae8"
                                                : "#7e8294"

                                            opacity:
                                                appButton.isMinimized
                                                ? 0.45
                                                : appButton.isActive
                                                ? 1.0
                                                : 0.82

                                            Behavior on color {
                                                ColorAnimation { duration: 120 }
                                            }

                                            Behavior on opacity {
                                                NumberAnimation { duration: 120 }
                                            }

                                            Behavior on height {
                                                NumberAnimation {
                                                    duration: 120
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Timer {
                                id: tooltipTimer

                                interval: 450
                                repeat: false

                                onTriggered: {
                                    if (
                                        appMouse.containsMouse
                                        && !contextMenu.visible
                                    ) {
                                        tooltipPopup.visible = true
                                    }
                                }
                            }

                            PopupWindow {
                                id: tooltipPopup

                                anchor.item: appButton

                                anchor.rect.x:
                                    Math.round(
                                        (appButton.width - implicitWidth) / 2
                                    )

                                anchor.rect.y: -8
                                anchor.edges: Edges.Top | Edges.Left
                                anchor.gravity: Edges.Top | Edges.Right
                                anchor.adjustment:
                                    PopupAdjustment.SlideX
                                    | PopupAdjustment.FlipY

                                implicitWidth: 220
                                implicitHeight: 52
                                color: "transparent"
                                grabFocus: false
                                visible: false

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 7
                                    color: "#2b2d3a"
                                    border.width: 1
                                    border.color: "#3f445b"

                                    Column {
                                        anchors {
                                            fill: parent
                                            leftMargin: 12
                                            rightMargin: 12
                                            topMargin: 8
                                            bottomMargin: 7
                                        }

                                        spacing: 3

                                        Text {
                                            width: parent.width
                                            text: appButton.appName
                                            elide: Text.ElideRight
                                            color: "#e1e3e4"
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Text {
                                            width: parent.width
                                            text: appButton.statusText

                                            color:
                                                appButton.isActive
                                                ? "#6dcae8"
                                                : appButton.isRunning
                                                ? "#7e8294"
                                                : "#5a5e7a"

                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 8
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            PopupWindow {
                                id: contextMenu

                                anchor.item: appButton

                                anchor.rect.x:
                                    Math.round(
                                        (appButton.width - implicitWidth) / 2
                                    )

                                anchor.rect.y: -8
                                anchor.edges: Edges.Top | Edges.Left
                                anchor.gravity: Edges.Top | Edges.Right
                                anchor.adjustment:
                                    PopupAdjustment.SlideX
                                    | PopupAdjustment.FlipY

                                implicitWidth: 210
                                implicitHeight: 224
                                color: "transparent"
                                grabFocus: true
                                visible: false

                                onVisibleChanged: {
                                    dockWindow.contextMenuOpen = visible

                                    if (visible) {
                                        tooltipPopup.visible = false
                                        dockWindow.showDock()
                                    } else {
                                        dockWindow.scheduleHide()
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 9
                                    color: "#2b2d3a"
                                    border.width: 1
                                    border.color: "#3f445b"

                                    Rectangle {
                                        id: menuHeader

                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            topMargin: 8
                                            leftMargin: 8
                                            rightMargin: 8
                                        }

                                        height: 42
                                        radius: 6
                                        color: "#333648"

                                        Row {
                                            anchors {
                                                fill: parent
                                                leftMargin: 10
                                                rightMargin: 10
                                            }

                                            spacing: 8

                                            IconImage {
                                                anchors.verticalCenter:
                                                    parent.verticalCenter

                                                implicitSize: 24

                                                source:
                                                    Quickshell.iconPath(
                                                        appButton.iconName,
                                                        "application-x-executable"
                                                    )
                                            }

                                            Column {
                                                anchors.verticalCenter:
                                                    parent.verticalCenter

                                                width: parent.width - 42
                                                spacing: 1

                                                Text {
                                                    width: parent.width
                                                    text: appButton.appName
                                                    elide: Text.ElideRight
                                                    color: "#e1e3e4"
                                                    font.family: "JetBrains Mono"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }

                                                Text {
                                                    text:
                                                        appButton.isRunning
                                                        ? appButton.windowCount
                                                            + (
                                                                appButton.windowCount === 1
                                                                ? " WINDOW"
                                                                : " WINDOWS"
                                                            )
                                                        : "NOT RUNNING"

                                                    color:
                                                        appButton.isActive
                                                        ? "#6dcae8"
                                                        : "#7e8294"

                                                    font.family: "JetBrains Mono"
                                                    font.pixelSize: 7
                                                    font.bold: true
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        anchors {
                                            top: menuHeader.bottom
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                            topMargin: 8
                                            leftMargin: 8
                                            rightMargin: 8
                                            bottomMargin: 8
                                        }

                                        spacing: 4

                                        Rectangle {
                                            width: parent.width
                                            height: 34
                                            radius: 5

                                            color:
                                                openMouse.containsMouse
                                                ? "#393e53"
                                                : "transparent"

                                            Text {
                                                anchors {
                                                    left: parent.left
                                                    verticalCenter:
                                                        parent.verticalCenter
                                                    leftMargin: 10
                                                }

                                                text:
                                                    appButton.isRunning
                                                    ? "ACTIVATE"
                                                    : "OPEN"

                                                color: "#e1e3e4"
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: openMouse

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape:
                                                    Qt.PointingHandCursor

                                                onClicked: {
                                                    contextMenu.visible = false

                                                    if (appButton.isRunning) {
                                                        root.windowService.activate(
                                                            appButton.targetWindowId
                                                        )
                                                    } else {
                                                        root.launchApp(
                                                            modelData,
                                                            appButton.desktopEntry
                                                        )
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 34
                                            radius: 5

                                            color:
                                                newMouse.containsMouse
                                                ? "#393e53"
                                                : "transparent"

                                            Text {
                                                anchors {
                                                    left: parent.left
                                                    verticalCenter:
                                                        parent.verticalCenter
                                                    leftMargin: 10
                                                }

                                                text: "NEW WINDOW"
                                                color: "#bb97ee"
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: newMouse

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape:
                                                    Qt.PointingHandCursor

                                                onClicked: {
                                                    contextMenu.visible = false

                                                    root.launchApp(
                                                        modelData,
                                                        appButton.desktopEntry
                                                    )
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 34
                                            radius: 5

                                            opacity:
                                                appButton.isRunning
                                                ? 1.0
                                                : 0.35

                                            color:
                                                minimizeMouse.containsMouse
                                                && appButton.isRunning
                                                ? "#393e53"
                                                : "transparent"

                                            Text {
                                                anchors {
                                                    left: parent.left
                                                    verticalCenter:
                                                        parent.verticalCenter
                                                    leftMargin: 10
                                                }

                                                text: "MINIMIZE"
                                                color: "#7e8294"
                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: minimizeMouse

                                                anchors.fill: parent
                                                enabled: appButton.isRunning
                                                hoverEnabled: true

                                                cursorShape:
                                                    enabled
                                                    ? Qt.PointingHandCursor
                                                    : Qt.ArrowCursor

                                                onClicked: {
                                                    contextMenu.visible = false

                                                    root.windowService.minimize(
                                                        appButton.targetWindowId
                                                    )
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: parent.width
                                            height: 34
                                            radius: 5

                                            opacity:
                                                appButton.isRunning
                                                ? 1.0
                                                : 0.35

                                            color:
                                                closeMouse.containsMouse
                                                && appButton.isRunning
                                                ? "#55393d"
                                                : "transparent"

                                            Text {
                                                anchors {
                                                    left: parent.left
                                                    verticalCenter:
                                                        parent.verticalCenter
                                                    leftMargin: 10
                                                }

                                                text: "CLOSE WINDOW"

                                                color:
                                                    appButton.isRunning
                                                    ? "#fb617e"
                                                    : "#7e8294"

                                                font.family: "JetBrains Mono"
                                                font.pixelSize: 9
                                                font.bold: true
                                            }

                                            MouseArea {
                                                id: closeMouse

                                                anchors.fill: parent
                                                enabled: appButton.isRunning
                                                hoverEnabled: true

                                                cursorShape:
                                                    enabled
                                                    ? Qt.PointingHandCursor
                                                    : Qt.ArrowCursor

                                                onClicked: {
                                                    contextMenu.visible = false

                                                    root.closeWindow(
                                                        appButton.targetWindowId
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: appMouse

                                anchors.fill: parent
                                hoverEnabled: true

                                acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.MiddleButton
                                    | Qt.RightButton

                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    tooltipTimer.restart()
                                }

                                onExited: {
                                    tooltipTimer.stop()
                                    tooltipPopup.visible = false
                                }

                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        tooltipTimer.stop()
                                        tooltipPopup.visible = false
                                        contextMenu.visible = true
                                        return
                                    }

                                    if (mouse.button === Qt.MiddleButton) {
                                        root.launchApp(
                                            modelData,
                                            appButton.desktopEntry
                                        )
                                        return
                                    }

                                    if (!appButton.isRunning) {
                                        root.launchApp(
                                            modelData,
                                            appButton.desktopEntry
                                        )
                                        return
                                    }

                                    if (
                                        appButton.isActive
                                        && modelData.activeWindowId !== ""
                                    ) {
                                        root.windowService.minimize(
                                            modelData.activeWindowId
                                        )
                                        return
                                    }

                                    if (modelData.representativeId !== "") {
                                        root.windowService.activate(
                                            modelData.representativeId
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


import QtQuick
import Quickshell
import Quickshell.Widgets

import org.kde.taskmanager as TaskManager


Scope {
    id: root


    /*
     * ============================================================
     * PINNED APPLICATIONS
     *
     * KDE TasksModel používá applications: URL.
     * Běžící aplikace se k nim přidají automaticky.
     * ============================================================
     */

    readonly property list<string> pinnedLaunchers: [
        "applications:firefox.desktop",
        "applications:org.kde.dolphin.desktop",
        "applications:Alacritty.desktop"
    ]


    /*
     * ============================================================
     * DESKTOP ENTRY LOOKUP
     * ============================================================
     */

    function desktopEntryFor(
        appId,
        launcherUrl,
        appName
    ) {
        /*
         * 1. Launcher URL
         *
         * applications:firefox.desktop
         */

        const launcher =
            String(launcherUrl || "")

        if (
            launcher.startsWith(
                "applications:"
            )
        ) {
            const id =
                launcher.substring(
                    "applications:".length
                )

            let entry =
                DesktopEntries.byId(id)

            if (entry !== null) {
                return entry
            }
        }


        /*
         * 2. KDE AppId
         */

        const id =
            String(appId || "")

        if (id.length > 0) {
            let exactId =
                id.endsWith(".desktop")
                    ? id
                    : id + ".desktop"

            let entry =
                DesktopEntries.byId(
                    exactId
                )

            if (entry !== null) {
                return entry
            }


            entry =
                DesktopEntries
                    .heuristicLookup(id)

            if (entry !== null) {
                return entry
            }
        }


        /*
         * 3. Application name fallback
         */

        const name =
            String(appName || "")

        if (name.length > 0) {
            return DesktopEntries
                .heuristicLookup(name)
        }


        return null
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
             * KDE TASK MODEL
             *
             * Tenhle model dělá většinu těžké práce:
             *
             * - launchery
             * - běžící okna
             * - matching launcher <-> window
             * - aktivní aplikace
             * - focus / activation
             * - multiple windows
             * ====================================================
             */

            TaskManager.TasksModel {
                id: tasksModel


                /*
                 * Pinned apps.
                 */

                launcherList:
                    root.pinnedLaunchers


                /*
                 * Běžící okno připnuté aplikace
                 * převezme pozici launcheru.
                 */

                separateLaunchers: false

                launchInPlace: true

                hideActivatedLaunchers: false


                /*
                 * Jedna ikona za aplikaci.
                 *
                 * Více Firefox oken tedy nebude
                 * znamenat 5 Firefox ikon.
                 */

                groupMode:
                    TaskManager.TasksModel
                        .GroupApplications

                groupInline: false


                /*
                 * Zachováme pořadí pinned ikon.
                 * Ostatní běžící aplikace se
                 * objeví za nimi.
                 */

                sortMode:
                    TaskManager.TasksModel
                        .SortManual

                taskReorderingEnabled: false
            }


            /*
             * ====================================================
             * INPUT MASK
             * ====================================================
             */

            mask: Region {
                x: dockSurface.x
                y: dockSurface.y

                width: dockSurface.width
                height: dockSurface.height

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
                 * TASKS
                 * =================================================
                 */

                Row {
                    id: dockRow

                    anchors.centerIn: parent

                    spacing: 6


                    Repeater {
                        model: tasksModel


                        delegate: Rectangle {
                            id: appButton


                            /*
                             * =====================================
                             * MODEL
                             * =====================================
                             */

                            required property int index


                            readonly property bool active:
                                Boolean(model.IsActive)


                            readonly property bool running:
                                Boolean(model.IsWindow)
                                || Boolean(
                                    model.IsGroupParent
                                )


                            readonly property bool launcher:
                                Boolean(model.IsLauncher)


                            readonly property bool pinned:
                                launcher
                                || Boolean(
                                    model.HasLauncher
                                )


                            readonly property bool minimized:
                                Boolean(
                                    model.IsMinimized
                                )


                            readonly property bool attention:
                                Boolean(
                                    model
                                        .IsDemandingAttention
                                )


                            readonly property int windowCount:
                                Boolean(
                                    model.IsGroupParent
                                )
                                    ? Number(
                                        model.ChildCount || 0
                                    )
                                    : running
                                        ? 1
                                        : 0


                            readonly property string appName:
                                String(
                                    model.AppName
                                    || model.display
                                    || model.AppId
                                    || "Application"
                                )


                            readonly property string appId:
                                String(
                                    model.AppId || ""
                                )


                            readonly property string launcherUrl:
                                String(
                                    model.LauncherUrl || ""
                                )


                            /*
                             * =====================================
                             * DESKTOP ENTRY
                             * =====================================
                             */

                            readonly property var desktopEntry:
                                root.desktopEntryFor(
                                    appId,
                                    launcherUrl,
                                    appName
                                )


                            readonly property string iconName:
                                desktopEntry !== null
                                && desktopEntry.icon
                                    ? desktopEntry.icon
                                    : "application-x-executable"


                            /*
                             * =====================================
                             * GEOMETRY
                             * =====================================
                             */

                            width: 54
                            height: 54

                            radius: 8


                            /*
                             * =====================================
                             * BACKGROUND
                             * =====================================
                             */

                            color:
                                active
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
                                        : active
                                            ? 39
                                            : 36


                                source:
                                    Quickshell.iconPath(
                                        appButton.iconName,
                                        "application-x-executable"
                                    )


                                Behavior on implicitSize {
                                    NumberAnimation {
                                        duration: 110

                                        easing.type:
                                            Easing.OutCubic
                                    }
                                }


                                opacity:
                                    appButton.minimized
                                        ? 0.62
                                        : 1.0


                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }
                                }
                            }


                            /*
                             * =====================================
                             * WINDOW COUNT
                             *
                             * Zobrazí se pouze pokud má aplikace
                             * více než jedno okno.
                             * =====================================
                             */

                            Rectangle {
                                visible:
                                    appButton.windowCount > 1

                                anchors {
                                    top: parent.top
                                    right: parent.right

                                    topMargin: 3
                                    rightMargin: 3
                                }

                                width: 17
                                height: 17

                                radius: 8.5

                                color: "#423f59"


                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        appButton.windowCount

                                    color: "#bb97ee"

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }


                            /*
                             * =====================================
                             * RUNNING / ACTIVE INDICATOR
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
                                    appButton.active
                                        ? 24
                                        : appButton.running
                                            ? 12
                                            : 0

                                height:
                                    appButton.active
                                        ? 3
                                        : 2

                                radius: 2


                                color:
                                    appButton.attention
                                        ? "#fb617e"
                                        : appButton.active
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
                             * ATTENTION MARKER
                             * =====================================
                             */

                            Rectangle {
                                visible:
                                    appButton.attention

                                anchors {
                                    top: parent.top
                                    left: parent.left

                                    topMargin: 5
                                    leftMargin: 5
                                }

                                width: 7
                                height: 7

                                radius: 3.5

                                color: "#fb617e"


                                SequentialAnimation on opacity {
                                    running:
                                        appButton.attention

                                    loops:
                                        Animation.Infinite


                                    NumberAnimation {
                                        to: 0.25
                                        duration: 550
                                    }


                                    NumberAnimation {
                                        to: 1
                                        duration: 550
                                    }
                                }
                            }


                            /*
                             * =====================================
                             * INPUT
                             *
                             * Left:
                             *   launcher -> launch
                             *   window   -> activate
                             *
                             * Active window:
                             *   minimize
                             *
                             * Middle:
                             *   new instance
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
                                    const modelIndex =
                                        tasksModel.index(
                                            appButton.index,
                                            0
                                        )


                                    /*
                                     * Middle click:
                                     * always try new instance.
                                     */

                                    if (
                                        mouse.button
                                        === Qt.MiddleButton
                                    ) {
                                        tasksModel
                                            .requestNewInstance(
                                                modelIndex
                                            )

                                        return
                                    }


                                    /*
                                     * Clicking active window:
                                     * minimize it.
                                     */

                                    if (
                                        appButton.active
                                        && appButton.running
                                        && Boolean(
                                            model.IsMinimizable
                                        )
                                    ) {
                                        tasksModel
                                            .requestToggleMinimized(
                                                modelIndex
                                            )

                                        return
                                    }


                                    /*
                                     * Otherwise:
                                     *
                                     * - launch pinned app
                                     * - activate existing window
                                     * - switch workspace if needed
                                     */

                                    tasksModel
                                        .requestActivate(
                                            modelIndex
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

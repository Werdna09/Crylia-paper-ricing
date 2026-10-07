import QtQuick
import Quickshell
import Quickshell.Io


Scope {
    id: root


    /*
     * ============================================================
     * PUBLIC STATE
     * ============================================================
     *
     * applications:
     *
     * [
     *     {
     *         key: "firefox",
     *         desktopFile: "firefox",
     *         resourceClass: "firefox",
     *         windowCount: 1,
     *         active: true,
     *         minimized: false,
     *         activeWindowId: "{...}",
     *         representativeId: "{...}",
     *         windows: [...]
     *     }
     * ]
     * ============================================================
     */

    property var applications: []

    readonly property int applicationCount:
        applications.length


    /*
     * ============================================================
     * KWIN QUERY
     * ============================================================
     */

    readonly property string queryScript:
        "var result = [];"
        + "var windows = workspace.stackingOrder;"
        + "for (var i = 0; i < windows.length; i++) {"
        + "    var w = windows[i];"
        + "    if ("
        + "        w.deleted"
        + "        || w.skipTaskbar"
        + "        || w.specialWindow"
        + "    ) {"
        + "        continue;"
        + "    }"
        + "    if ("
        + "        !w.normalWindow"
        + "        && !w.dialog"
        + "    ) {"
        + "        continue;"
        + "    }"
        + "    result.push({"
        + "        id: String(w.internalId),"
        + "        caption: String(w.caption || ''),"
        + "        desktopFile: String(w.desktopFileName || ''),"
        + "        resourceClass: String(w.resourceClass || ''),"
        + "        active: Boolean(w.active),"
        + "        minimized: Boolean(w.minimized),"
        + "        normalWindow: Boolean(w.normalWindow),"
        + "        dialog: Boolean(w.dialog)"
        + "    });"
        + "}"
        + "output_result(JSON.stringify(result));"


    /*
     * ============================================================
     * HELPERS
     * ============================================================
     */

    function normalizeKey(value) {
        let result =
            String(value || "").trim()


        /*
         * desktopFileName může být v některých
         * případech i absolutní cesta.
         */

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


    function windowKey(windowData) {
        let key =
            root.normalizeKey(
                windowData.desktopFile
            )


        if (key !== "") {
            return key
        }


        key =
            root.normalizeKey(
                windowData.resourceClass
            )


        if (key !== "") {
            return key
        }


        return root.normalizeKey(
            windowData.caption
        )
    }


    /*
     * ============================================================
     * PARSE KWIN SNAPSHOT
     * ============================================================
     */

    function applySnapshot(text) {
        const source =
            String(text || "").trim()


        if (source === "") {
            return
        }


        let windows


        try {
            windows =
                JSON.parse(source)
        } catch (error) {
            console.warn(
                "WindowStatus: cannot parse kdotool output:",
                error
            )

            return
        }


        if (!Array.isArray(windows)) {
            console.warn(
                "WindowStatus: kdotool did not return an array"
            )

            return
        }


        const groups = {}


        /*
         * workspace.stackingOrder je seřazené.
         *
         * Pozdější okno tedy používáme jako
         * reprezentativní okno aplikace.
         */

        for (
            let i = 0;
            i < windows.length;
            i++
        ) {
            const windowData =
                windows[i]

            const key =
                root.windowKey(
                    windowData
                )


            if (key === "") {
                continue
            }


            if (groups[key] === undefined) {
                groups[key] = {
                    key: key,

                    desktopFile:
                        String(
                            windowData.desktopFile
                            || ""
                        ),

                    resourceClass:
                        String(
                            windowData.resourceClass
                            || ""
                        ),

                    caption:
                        String(
                            windowData.caption
                            || ""
                        ),

                    active: false,

                    minimized: true,

                    windowCount: 0,

                    activeWindowId: "",

                    representativeId: "",

                    windows: []
                }
            }


            const group =
                groups[key]


            group.windows.push(
                windowData
            )


            group.windowCount++


            /*
             * Poslední v stacking order
             * bude reprezentativní.
             */

            group.representativeId =
                String(
                    windowData.id || ""
                )


            /*
             * Pokud existuje aktivní okno,
             * má samozřejmě přednost.
             */

            if (windowData.active) {
                group.active = true

                group.activeWindowId =
                    String(
                        windowData.id || ""
                    )

                group.representativeId =
                    group.activeWindowId
            }


            /*
             * Aplikace je považována za
             * minimalizovanou pouze tehdy,
             * pokud jsou minimalizována
             * všechna její okna.
             */

            if (!windowData.minimized) {
                group.minimized = false
            }


            /*
             * U první položky uchováme
             * desktopFile, pokud ji pozdější
             * okno nemá vyplněnou.
             */

            if (
                group.desktopFile === ""
                && windowData.desktopFile
            ) {
                group.desktopFile =
                    String(
                        windowData.desktopFile
                    )
            }


            if (
                group.resourceClass === ""
                && windowData.resourceClass
            ) {
                group.resourceClass =
                    String(
                        windowData.resourceClass
                    )
            }
        }


        const result = []


        for (const key in groups) {
            result.push(
                groups[key]
            )
        }


        /*
         * Stabilní pořadí dynamických aplikací.
         *
         * Pinned aplikace si později řadí
         * BottomDock sám.
         */

        result.sort(
            (a, b) =>
                a.key.localeCompare(
                    b.key
                )
        )


        root.applications =
            result
    }


    /*
     * ============================================================
     * REFRESH
     * ============================================================
     */

    function refresh() {
        if (queryProcess.running) {
            return
        }

        queryProcess.running = true
    }


    function refreshSoon(delay) {
        delayedRefresh.interval =
            delay === undefined
                ? 250
                : delay

        delayedRefresh.restart()
    }


    /*
     * ============================================================
     * WINDOW ACTIONS
     * ============================================================
     */

    function activate(windowId) {
        const id =
            String(windowId || "")


        if (id === "") {
            return
        }


        Quickshell.execDetached([
            "kdotool",
            "windowactivate",
            id
        ])


        root.refreshSoon(180)
    }


    function minimize(windowId) {
        const id =
            String(windowId || "")


        if (id === "") {
            return
        }


        Quickshell.execDetached([
            "kdotool",
            "windowminimize",
            id
        ])


        root.refreshSoon(180)
    }


    /*
     * ============================================================
     * KDTOOL PROCESS
     * ============================================================
     */

    Process {
        id: queryProcess

        command: [
            "kdotool",
            "kwinscript",
            "--inline",
            root.queryScript
        ]


        stdout: StdioCollector {
            onStreamFinished: {
                root.applySnapshot(
                    this.text
                )
            }
        }
    }


    /*
     * ============================================================
     * REGULAR POLLING
     *
     * kdotool skript spouštíme jen jednou za sekundu.
     * Pro taskbar je to dostatečně rychlé a KWin
     * zbytečně nebombardujeme.
     * ============================================================
     */

    Timer {
        interval: 1000

        repeat: true
        running: true

        onTriggered: {
            root.refresh()
        }
    }


    /*
     * Refresh krátce po aktivaci/minimalizaci.
     */

    Timer {
        id: delayedRefresh

        interval: 250

        repeat: false

        onTriggered: {
            root.refresh()
        }
    }


    Component.onCompleted: {
        root.refresh()
    }
}

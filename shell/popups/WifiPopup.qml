import QtQuick
import Quickshell
import Quickshell.Networking

PopupWindow {
    id: root

    required property Item anchorItem
    required property var networkService

    property var selectedNetwork: null
    property string errorText: ""

    implicitWidth: 360
    implicitHeight: 430

    color: "transparent"
    grabFocus: true

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: 7


    function securityLabel(type) {
        switch (type) {
        case WifiSecurityType.Open:
            return "Open"

        case WifiSecurityType.Owe:
            return "OWE"

        case WifiSecurityType.WpaPsk:
            return "WPA"

        case WifiSecurityType.Wpa2Psk:
            return "WPA2"

        case WifiSecurityType.Sae:
            return "WPA3"

        case WifiSecurityType.WpaEap:
            return "WPA Enterprise"

        case WifiSecurityType.Wpa2Eap:
            return "WPA2 Enterprise"

        case WifiSecurityType.StaticWep:
            return "WEP"

        case WifiSecurityType.DynamicWep:
            return "Dynamic WEP"

        default:
            return "Secured"
        }
    }


    function canUsePsk(wifi) {
        return wifi.security === WifiSecurityType.WpaPsk
            || wifi.security === WifiSecurityType.Wpa2Psk
            || wifi.security === WifiSecurityType.Sae
    }


    function activateNetwork(wifi) {
        root.errorText = ""

        if (wifi.connected) {
            wifi.disconnect()

            root.selectedNetwork = null
            passwordInput.text = ""

            return
        }

        if (
            wifi.known
            || wifi.security === WifiSecurityType.Open
            || wifi.security === WifiSecurityType.Owe
        ) {
            root.selectedNetwork = null
            passwordInput.text = ""

            wifi.connect()

            return
        }

        if (root.canUsePsk(wifi)) {
            root.selectedNetwork = wifi

            passwordInput.text = ""
            passwordInput.forceActiveFocus()

            return
        }

        root.errorText =
            "Síť vyžaduje pokročilé přihlášení."
    }


    Connections {
        target: root.selectedNetwork


        function onConnectionFailed(reason) {
            if (
                reason
                === ConnectionFailReason.NoSecrets
            ) {
                root.errorText =
                    "Heslo nebylo přijato."
            } else {
                root.errorText =
                    "Připojení selhalo."
            }
        }


        function onConnectedChanged() {
            if (
                root.selectedNetwork !== null
                && root.selectedNetwork.connected
            ) {
                root.selectedNetwork = null
                root.errorText = ""

                passwordInput.text = ""
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

            text: "Wi-Fi"

            color: "#e1e3e4"

            font.family: "JetBrains Mono"
            font.pixelSize: 15
            font.bold: true
        }


        Rectangle {
            anchors {
                right: parent.right
                verticalCenter: title.verticalCenter

                rightMargin: 16
            }

            width: 44
            height: 24

            radius: 12

            color:
                root.networkService.wifiEnabled
                    ? "#8cc6df"
                    : "#393e53"


            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }


            Rectangle {
                width: 18
                height: 18

                radius: 9

                anchors.verticalCenter:
                    parent.verticalCenter

                x:
                    root.networkService.wifiEnabled
                        ? parent.width - width - 3
                        : 3

                color:
                    root.networkService.wifiEnabled
                        ? "#181a1c"
                        : "#7e8294"


                Behavior on x {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }


            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                onClicked: {
                    root.networkService.toggleWifi()
                }
            }
        }


        Rectangle {
            id: currentNetworkCard

            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right

                topMargin: 14
                leftMargin: 14
                rightMargin: 14
            }

            height: 58

            radius: 7

            color:
                root.networkService.wifiConnected
                    ? "#354157"
                    : "#333648"

            border.width: 1

            border.color:
                root.networkService.wifiConnected
                    ? "#6dcae8"
                    : "#393e53"


            Text {
                anchors {
                    top: parent.top
                    left: parent.left

                    topMargin: 10
                    leftMargin: 12
                }

                text:
                    root.networkService.wifiConnected
                        ? root.networkService.wifiName
                        : root.networkService.wifiEnabled
                            ? "Nepřipojeno"
                            : "Wi-Fi vypnuta"

                color: "#e1e3e4"

                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
            }


            Text {
                anchors {
                    bottom: parent.bottom
                    left: parent.left

                    bottomMargin: 9
                    leftMargin: 12
                }

                text:
                    root.networkService.wifiConnected
                        ? "Připojeno"
                        : root.networkService.wifiEnabled
                            ? "Vyber síť níže"
                            : "Zapni Wi-Fi"

                color:
                    root.networkService.wifiConnected
                        ? "#6dcae8"
                        : "#7e8294"

                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }


            Text {
                visible:
                    root.networkService.wifiConnected
                    && root.networkService.currentWifi !== null

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter

                    rightMargin: 12
                }

                text:
                    root.networkService.currentWifi !== null
                        ? Math.round(
                            root.networkService
                                .currentWifi
                                .signalStrength
                            * 100
                        ) + "%"
                        : ""

                color: "#8cc6df"

                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true
            }
        }


        Text {
            id: networksTitle

            anchors {
                top: currentNetworkCard.bottom
                left: parent.left

                topMargin: 14
                leftMargin: 16
            }

            text: "Dostupné sítě"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 10
            font.bold: true
        }


        ListView {
            id: networkList

            anchors {
                top: networksTitle.bottom
                left: parent.left
                right: parent.right
                bottom: passwordPanel.top

                topMargin: 7
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 7
            }

            clip: true
            spacing: 3

            model:
                root.networkService.wifiEnabled
                    ? root.networkService.wifiNetworks
                    : null


            delegate: Rectangle {
                id: networkRow

                required property var modelData

                width: ListView.view.width
                height: 49

                radius: 6

                color:
                    modelData.connected
                        ? "#354157"
                        : networkMouse.containsMouse
                            ? "#333648"
                            : "transparent"

                border.width:
                    modelData.connected
                        ? 1
                        : 0

                border.color: "#6dcae8"


                Text {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: signalText.left

                        topMargin: 7
                        leftMargin: 9
                        rightMargin: 8
                    }

                    text:
                        modelData.name.length > 0
                            ? modelData.name
                            : "<hidden>"

                    elide: Text.ElideRight

                    color:
                        modelData.connected
                            ? "#e1e3e4"
                            : "#c8cad0"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: modelData.connected
                }


                Text {
                    anchors {
                        left: parent.left
                        bottom: parent.bottom

                        leftMargin: 9
                        bottomMargin: 7
                    }

                    text:
                        modelData.connected
                            ? "Připojeno"
                            : modelData.known
                                ? "Uloženo · "
                                    + root.securityLabel(
                                        modelData.security
                                    )
                                : root.securityLabel(
                                    modelData.security
                                )

                    color:
                        modelData.connected
                            ? "#6dcae8"
                            : modelData.known
                                ? "#9ed06c"
                                : "#7e8294"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 9
                }


                Text {
                    id: signalText

                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 9
                    }

                    text:
                        modelData.stateChanging
                            ? "…"
                            : Math.round(
                                modelData.signalStrength
                                * 100
                            ) + "%"

                    color:
                        modelData.signalStrength >= 0.65
                            ? "#9ed06c"
                            : modelData.signalStrength >= 0.35
                                ? "#edc763"
                                : "#fb617e"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.bold: true
                }


                MouseArea {
                    id: networkMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.activateNetwork(
                            networkRow.modelData
                        )
                    }
                }
            }
        }


        Text {
            visible:
                root.networkService.wifiEnabled
                && networkList.count === 0

            anchors.centerIn: networkList

            text: "Hledám sítě…"

            color: "#7e8294"

            font.family: "JetBrains Mono"
            font.pixelSize: 11
        }


        Rectangle {
            id: passwordPanel

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                leftMargin: 10
                rightMargin: 10
                bottomMargin: 10
            }

            visible:
                root.selectedNetwork !== null

            height:
                visible
                    ? 98
                    : 0

            radius: 7

            color: "#333648"

            border.width: 1
            border.color: "#423f59"


            Text {
                id: passwordTitle

                anchors {
                    top: parent.top
                    left: parent.left

                    topMargin: 8
                    leftMargin: 10
                }

                text:
                    root.selectedNetwork !== null
                        ? root.selectedNetwork.name
                        : ""

                color: "#bb97ee"

                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.bold: true
            }


            Rectangle {
                anchors {
                    left: parent.left
                    right: connectButton.left
                    bottom: parent.bottom

                    leftMargin: 10
                    rightMargin: 7
                    bottomMargin: 10
                }

                height: 32

                radius: 5

                color: "#252630"

                border.width: 1
                border.color: "#3f445b"


                TextInput {
                    id: passwordInput

                    anchors {
                        fill: parent

                        leftMargin: 9
                        rightMargin: 9
                    }

                    verticalAlignment:
                        TextInput.AlignVCenter

                    echoMode:
                        TextInput.Password

                    color: "#e1e3e4"
                    selectionColor: "#6dcae8"

                    font.family: "JetBrains Mono"
                    font.pixelSize: 11

                    onAccepted: {
                        connectButton.connectNow()
                    }
                }
            }


            Rectangle {
                id: connectButton

                anchors {
                    right: parent.right
                    bottom: parent.bottom

                    rightMargin: 10
                    bottomMargin: 10
                }

                width: 82
                height: 32

                radius: 5
                color: "#bb97ee"


                function connectNow() {
                    root.errorText = ""

                    if (
                        root.selectedNetwork === null
                    ) {
                        return
                    }

                    if (
                        passwordInput.text.length === 0
                    ) {
                        root.errorText =
                            "Zadej heslo."

                        return
                    }

                    root.selectedNetwork
                        .connectWithPsk(
                            passwordInput.text
                        )
                }


                Text {
                    anchors.centerIn: parent

                    text: "PŘIPOJIT"

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
                        connectButton.connectNow()
                    }
                }
            }


            Text {
                visible:
                    root.errorText.length > 0

                anchors {
                    left: passwordTitle.right
                    right: parent.right
                    top: parent.top

                    leftMargin: 8
                    rightMargin: 10
                    topMargin: 8
                }

                text: root.errorText

                horizontalAlignment:
                    Text.AlignRight

                elide:
                    Text.ElideRight

                color: "#fb617e"

                font.family: "JetBrains Mono"
                font.pixelSize: 9
            }
        }
    }


    onVisibleChanged: {
        if (visible) {
            root.networkService.enableScanner()
        } else {
            root.selectedNetwork = null
            root.errorText = ""

            passwordInput.text = ""
        }
    }
}

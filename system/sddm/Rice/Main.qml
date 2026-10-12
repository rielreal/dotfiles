import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Rectangle {
    id: root

    readonly property real unit: height / 1440
    readonly property color hourColor: config.HourColor
    readonly property color minuteColor: config.MinuteColor
    readonly property color textColor: config.TextColor
    readonly property color mutedColor: config.MutedColor
    readonly property color fieldColor: config.FieldColor
    readonly property color fieldBorderColor: config.FieldBorderColor
    readonly property color failColor: config.FailColor
    readonly property string fontFamily: config.Font

    property int userIndex: Math.max(userModel.lastIndex, 0)
    property int sessionIndex: Math.max(sessionModel.lastIndex, 0)
    property string userName: userModel.lastUser
    property string sessionName: ""
    property bool loggingIn: false
    property bool failed: false

    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    function login() {
        if (loggingIn || userName === "")
            return
        loggingIn = true
        sddm.login(userName, password.text, sessionIndex)
    }

    width: Screen.width
    height: Screen.height
    color: fieldColor

    Connections {
        target: sddm

        function onLoginFailed() {
            root.loggingIn = false
            root.failed = true
            password.text = ""
            password.forceActiveFocus()
            shake.restart()
        }

        function onLoginSucceeded() {
            root.loggingIn = false
        }
    }

    Instantiator {
        model: userModel
        delegate: QtObject {
            required property int index
            required property string name
            Component.onCompleted: if (index === root.userIndex) root.userName = name
        }
    }

    Instantiator {
        model: sessionModel
        delegate: QtObject {
            required property int index
            required property string name
            readonly property bool current: index === root.sessionIndex
            onCurrentChanged: if (current) root.sessionName = name
            Component.onCompleted: if (current) root.sessionName = name
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: Number(config.Blur)
        blurMax: 64
        autoPaddingEnabled: false
        brightness: -Number(config.Dim) * 0.5
        saturation: 0.15
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.withAlpha(root.fieldColor, 0.25) }
            GradientStop { position: 0.55; color: root.withAlpha(root.fieldColor, 0.1) }
            GradientStop { position: 1.0; color: root.withAlpha(root.fieldColor, 0.6) }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            hours.text = Qt.formatTime(now, "HH")
            minutes.text = Qt.formatTime(now, "mm")
            day.text = Qt.formatDate(now, "dd MMM")
            weekday.text = Qt.formatDate(now, "dddd")
        }
    }

    Column {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -110 * root.unit
        spacing: 28 * root.unit

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: -120 * root.unit

            Text {
                id: hours
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.hourColor
                font.family: root.fontFamily
                font.weight: Font.DemiBold
                font.pixelSize: 290 * root.unit
            }

            Text {
                id: minutes
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.minuteColor
                font.family: root.fontFamily
                font.weight: Font.DemiBold
                font.pixelSize: 290 * root.unit
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: day
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.textColor
                font.family: root.fontFamily
                font.weight: Font.DemiBold
                font.pixelSize: 34 * root.unit
            }

            Text {
                id: weekday
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.withAlpha(root.textColor, 0.8)
                font.family: root.fontFamily
                font.weight: Font.Medium
                font.pixelSize: 26 * root.unit
            }
        }
    }

    Column {
        id: loginBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 110 * root.unit
        spacing: 16 * root.unit

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.userName
            color: root.textColor
            font.family: root.fontFamily
            font.weight: Font.Medium
            font.pixelSize: 24 * root.unit
            font.capitalization: Font.Capitalize

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8 * root.unit
                enabled: userModel.count > 1
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
            }
        }

        Rectangle {
            id: field
            width: 360 * root.unit
            height: 64 * root.unit
            radius: height / 2
            color: root.withAlpha(root.fieldColor, 0.72)
            border.width: 3 * root.unit
            border.color: root.failed ? root.failColor
                        : password.activeFocus ? root.withAlpha(root.fieldBorderColor, 0.85)
                        : root.withAlpha(root.fieldBorderColor, 0.45)

            Behavior on border.color { ColorAnimation { duration: 160 } }

            TextInput {
                id: password
                anchors.fill: parent
                anchors.leftMargin: 28 * root.unit
                anchors.rightMargin: 28 * root.unit
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                passwordMaskDelay: 0
                color: root.textColor
                selectionColor: root.withAlpha(root.fieldBorderColor, 0.5)
                font.family: root.fontFamily
                font.pixelSize: (text.length > 0 ? 30 : 22) * root.unit
                font.letterSpacing: text.length > 0 ? 6 * root.unit : 0
                clip: true
                focus: true
                enabled: !root.loggingIn
                cursorVisible: false
                cursorDelegate: Item {}
                onTextEdited: root.failed = false
                onAccepted: root.login()
                Keys.onEscapePressed: text = ""
                Component.onCompleted: forceActiveFocus()
            }

            Text {
                anchors.centerIn: parent
                visible: password.text.length === 0
                text: root.loggingIn ? "Logging in…" : root.failed ? "Wrong password" : "Password…"
                color: root.failed ? root.failColor : root.withAlpha(root.mutedColor, 0.9)
                font.family: root.fontFamily
                font.italic: !root.failed
                font.pixelSize: 22 * root.unit
            }

            SequentialAnimation {
                id: shake
                property real step: 10 * root.unit
                NumberAnimation { target: field; property: "x"; to: -shake.step; duration: 50 }
                NumberAnimation { target: field; property: "x"; to: shake.step; duration: 70 }
                NumberAnimation { target: field; property: "x"; to: -shake.step / 2; duration: 60 }
                NumberAnimation { target: field; property: "x"; to: 0; duration: 50 }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Caps Lock is on"
            color: root.mutedColor
            opacity: keyboard.capsLock ? 1 : 0
            font.family: root.fontFamily
            font.pixelSize: 18 * root.unit
        }
    }

    Item {
        id: sessionPicker
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 48 * root.unit
        anchors.bottomMargin: 40 * root.unit
        width: sessionLabel.width
        height: sessionLabel.height
        property bool open: false

        Text {
            id: sessionLabel
            text: root.sessionName
            color: sessionArea.containsMouse || sessionPicker.open ? root.textColor : root.mutedColor
            font.family: root.fontFamily
            font.pixelSize: 22 * root.unit

            MouseArea {
                id: sessionArea
                anchors.fill: parent
                anchors.margins: -10 * root.unit
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sessionPicker.open = !sessionPicker.open
            }
        }

        Rectangle {
            visible: sessionPicker.open
            anchors.left: parent.left
            anchors.leftMargin: -16 * root.unit
            anchors.bottom: sessionLabel.top
            anchors.bottomMargin: 16 * root.unit
            width: sessionList.width + 32 * root.unit
            height: sessionList.height + 20 * root.unit
            radius: 18 * root.unit
            color: root.withAlpha(root.fieldColor, 0.85)
            border.width: 2 * root.unit
            border.color: root.withAlpha(root.fieldBorderColor, 0.35)

            Column {
                id: sessionList
                anchors.centerIn: parent

                Repeater {
                    model: sessionModel
                    delegate: Text {
                        required property int index
                        required property string name
                        text: name
                        width: Math.max(implicitWidth, 260 * root.unit)
                        height: 44 * root.unit
                        verticalAlignment: Text.AlignVCenter
                        color: index === root.sessionIndex ? root.hourColor
                             : itemArea.containsMouse ? root.textColor : root.mutedColor
                        font.family: root.fontFamily
                        font.pixelSize: 22 * root.unit

                        MouseArea {
                            id: itemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.sessionIndex = index
                                sessionPicker.open = false
                                password.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 44 * root.unit
        anchors.bottomMargin: 34 * root.unit
        spacing: 20 * root.unit

        PowerButton {
            visible: sddm.canSuspend
            first: "M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"
            onClicked: sddm.suspend()
        }

        PowerButton {
            visible: sddm.canReboot
            first: "M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"
            second: "M3 3v5h5"
            onClicked: sddm.reboot()
        }

        PowerButton {
            visible: sddm.canPowerOff
            first: "M12 2v10"
            second: "M18.4 6.6a9 9 0 1 1-12.77.04"
            onClicked: sddm.powerOff()
        }
    }

    component IconStroke: ShapePath {
        required property color stroke
        strokeColor: stroke
        strokeWidth: 2
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
    }

    component PowerButton: Item {
        id: button
        property string first
        property string second
        readonly property color stroke: area.containsMouse ? root.hourColor : root.mutedColor
        signal clicked()

        width: 44 * root.unit
        height: width

        Shape {
            anchors.centerIn: parent
            width: 24
            height: 24
            scale: 30 * root.unit / 24
            preferredRendererType: Shape.CurveRenderer

            IconStroke {
                stroke: button.stroke
                PathSvg { path: button.first }
            }

            IconStroke {
                stroke: button.stroke
                PathSvg { path: button.second }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}

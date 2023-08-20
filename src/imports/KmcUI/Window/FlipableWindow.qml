import QtQuick
import QtQuick.Controls

Window {
    id: control
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Window

    property bool flipped: false
    property alias front: frontBg
    property alias back: backBg
    property int flipDuation: 350

    property alias resizable: frontBg.resizable
    property alias dragType: frontBg.dragType

    Flipable {
        id: flipable
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        front: WindowBackground {
            id: frontBg
            anchors.fill: parent
            window: control
            mouseAreaEnabled: !control.flipped
            palette: control.palette
        }
        back: WindowBackground {
            id: backBg
            anchors.fill: parent
            window: control
            mouseAreaEnabled: control.flipped
            resizable: frontBg.resizable
            dragType: frontBg.dragType
            palette: control.palette
        }

        transform: Rotation {
            id: rotation
            axis.x: 0
            axis.y: 1
            axis.z: 0
            angle: 0
        }

        transformOrigin: Item.Center

        states: State {
            PropertyChanges {
                target: rotation
                angle: 180
            }
            when: control.flipped
        }

        transitions: Transition {
            NumberAnimation {
                target: rotation
                property: "angle"
                duration: control.flipDuation
            }
            SequentialAnimation {
                NumberAnimation {
                    target: flipable
                    property: "scale"
                    duration: control.flipDuation / 2
                    from: 1
                    to: 0.5
                }
                NumberAnimation {
                    target: flipable
                    duration: control.flipDuation / 2
                    property: "scale"
                    from: 0.5
                    to: 1
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Window

Window {
    id: control

    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.ToolTip | Qt.WindowStaysOnTopHint
    opacity: 0
    property MouseArea mouseArea
    property alias delay: showPause.duration
    property alias timeout: hideTimer.interval
    property alias text: text.text
    property alias font: text.font
    property int padding: 5
    property int horizontalPadding: padding
    property int verticalPadding: padding
    property int cursorSize: 16
    property var parent
    readonly property bool mouseAreaEnabled: mouseArea?.enabled ?? false

    onMouseAreaEnabledChanged: close()

    onParentChanged: {
        for (var p = parent; p; p = p.parent) {
            for (var i = 0; i < p.children.length; ++i) {
                if (p.children[i] instanceof MouseArea) {
                    mouseArea = p.children[i]
                    return
                }
            }
        }
    }

    width: background.width + 5
    height: background.height + 5

    Rectangle {
        id: background
        palette {
            toolTipText: "#878787"
            toolTipBase: "white"
            shadow: "#8e8e8e"
        }
        anchors.left: parent.left
        anchors.top: parent.top
        width: text.contentWidth + 2 * control.horizontalPadding
        height: text.contentHeight + 2 * control.verticalPadding
        color: background.palette.toolTipBase
        border.width: 1
        border.color: "#E5E5E5"
        radius: 2
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowBlur: 0.5
            shadowEnabled: true
            shadowHorizontalOffset: 2
            shadowVerticalOffset: 2
            shadowColor: background.palette.shadow
        }

        Text {
            id: text
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            color: background.palette.toolTipText
        }
    }

    onVisibleChanged: {
        if (visible) {
            showAnim.restart()
            hideTimer.restart()
        }
    }

    SequentialAnimation {
        id: showAnim
        ScriptAction {
            script: {
                control.opacity = 0
            }
        }
        PauseAnimation {
            id: showPause
            duration: 1000
        }
        ScriptAction {
            script: {
                var globalMouse = mouseArea.mapToGlobal(Qt.point(mouseArea.mouseX,
                                                                 mouseArea.mouseY))
                x = Math.min(globalMouse.x, Screen.desktopAvailableWidth - background.width)
                y = globalMouse.y + cursorSize
            }
        }
        NumberAnimation {
            target: control
            property: "opacity"
            from: 0
            to: 1
            duration: 100
        }
    }

    Timer {
        id: hideTimer
        interval: 9000
        onTriggered: close()
    }
}

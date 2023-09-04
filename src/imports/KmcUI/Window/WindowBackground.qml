import QtQuick
import QtQuick.Controls
import QtQuick.Window
import KmcUI.Controls
import KmcUI.Effects

Item {
    id: control

    // Not like TitleBar etc, WindowBackground is an internal component, so it doesn't need to find window
    required property Window window
    property bool mouseAreaEnabled: true
    property int margins: 10
    required property Item contentItem
    property Item background: Rectangle {
        id: backgroundRect
        radius: 4
        border {
            width: 1
            color: Qt.darker(effect.color, 1.5)
        }
        Binding {
            when: control.window.visibility === Window.Maximized
            backgroundRect.border.width: 0
            backgroundRect.radius: 0
        }
    }

    enum DragBehavior {
        NoDrag = 0,
        DragTitle,
        DragWindow
    }

    property bool resizable: false
    property int dragBehavior: WindowBackground.DragWindow
    property alias titleButton: title.titleButton
    property alias appIcon: title.appIcon
    property alias title: title
    property Item menuBar

    palette {
        shadow: "#88333333"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: mouseAreaEnabled
        property int edgeFlag: 0

        onPressed: {
            if (resizable && cursorShape !== Qt.ArrowCursor) {
                // resize
                window.startSystemResize(edgeFlag)
            } else {
                // drag
                if (dragBehavior !== WindowBackground.NoDrag && mouseX >= margins
                        && mouseX <= width - margins && mouseY >= margins
                        && mouseY <= height - margins) {
                    // is in region?
                    if (dragBehavior === WindowBackground.DragWindow || mouseY <= title.height) {
                        window.startSystemMove()
                    }
                }
            }
        }

        onDoubleClicked: {
            if (title.contains(Qt.point(mouseX, mouseY))) {
                if (window.visibility === Window.Maximized) {
                    window?.showNormal()
                } else {
                    window?.showMaximized()
                }
            }
        }

        onExited: cursorShape = Qt.ArrowCursor

        onPositionChanged: {
            var blurSize = 2
            edgeFlag = 0
            if (window.visibility !== Window.Maximized && mouseX >= margins - blurSize
                    && mouseX <= width - margins + blurSize
                    && mouseY >= margins - blurSize && mouseY <= height - margins + blurSize) {
                if (Math.abs(mouseX - margins) <= blurSize)
                    edgeFlag |= Qt.LeftEdge
                else if (Math.abs(mouseX - width + margins) <= blurSize)
                    edgeFlag |= Qt.RightEdge
                if (Math.abs(mouseY - margins) <= blurSize)
                    edgeFlag |= Qt.TopEdge
                else if (Math.abs(mouseY - height + margins) <= blurSize)
                    edgeFlag |= Qt.BottomEdge
            }

            if (resizable) {
                if (edgeFlag === Qt.LeftEdge || edgeFlag === Qt.RightEdge)
                    cursorShape = Qt.SizeHorCursor
                else if (edgeFlag === Qt.TopEdge || edgeFlag === Qt.BottomEdge)
                    cursorShape = Qt.SizeVerCursor
                else if (edgeFlag === (Qt.TopEdge | Qt.LeftEdge)
                         || edgeFlag === (Qt.BottomEdge | Qt.RightEdge))
                    cursorShape = Qt.SizeFDiagCursor
                else if (edgeFlag === (Qt.TopEdge | Qt.RightEdge)
                         || (edgeFlag === (Qt.BottomEdge | Qt.LeftEdge)))
                    cursorShape = Qt.SizeBDiagCursor
                else
                    cursorShape = Qt.ArrowCursor
            }
        }
    }

    RectangularGlow {
        id: effect
        anchors.fill: mainRect
        z: -2
        glowRadius: 5
        scale: background.scale
        color: control.palette.shadow
        cornerRadius: glowRadius
    }

    Item {
        id: mainRect
        anchors.fill: parent
        anchors.margins: control.margins
        clip: true

        TitleBar {
            id: title
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: 30
            window: control.window
            buttonEnabled: control.mouseAreaEnabled

            buttons {
                hover.buttonColor: "#25ffffff"
                press.buttonColor: "#43ffffff"
            }

            Component.onCompleted: {
                let closeButton = title.buttonByName("Close")
                closeButton.hover.buttonColor = "#E81123"
                closeButton.hover.iconColor = "white"

                closeButton.press.buttonColor = "#AAE81123"
                closeButton.press.iconColor = "white"
            }
        }

        Binding {
            control {
                contentItem {
                    parent: mainRect
                    anchors {
                        top: control.menuBar ? control.menuBar.bottom : title.bottom
                        left: title.left
                        right: title.right
                        bottom: mainRect.bottom
                    }
                }
                background {
                    parent: mainRect
                    anchors.fill: mainRect
                    z: -1
                }
            }
        }

        layer.enabled: !!control.background.radius
        layer.effect: ClipMask {
            // clip elements that are out of background
            source: mainRect
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Binding {
            when: menuBar !== undefined
            control.menuBar.parent: mainRect
            control.menuBar.anchors {
                top: title.bottom
                left: title.left
                right: title.right
            }
        }
    }

    Binding {
        when: control.window.visibility === Window.Maximized
        control.margins: 0
    }
}

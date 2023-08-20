import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Window
import KmcUI
import KmcUI.Controls

Item {
    id: control

    // Not like TitleBar etc, WindowBackground is an internal component, so it doesn't need to find window
    required property Window window
    property bool mouseAreaEnabled: true
    property int margin: 10
    required property Item contentItem
    property alias background: mainRect
    property bool resizable: false
    property int dragType: KmcUI.DragType.DragWindow
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
                if (dragType !== KmcUI.DragType.NoDrag && mouseX >= margin
                        && mouseX <= width - margin && mouseY >= margin
                        && mouseY <= height - margin) {
                    // is in region?
                    if (dragType === KmcUI.DragType.DragWindow || mouseY <= title.height) {
                        window.startSystemMove()
                    }
                }
            }
        }

        onExited: cursorShape = Qt.ArrowCursor

        onPositionChanged: {
            var blurSize = 2
            edgeFlag = 0
            if (window.visibility !== Window.Maximized && mouseX >= margin - blurSize
                    && mouseX <= width - margin + blurSize
                    && mouseY >= margin - blurSize && mouseY <= height - margin + blurSize) {
                if (Math.abs(mouseX - margin) <= blurSize)
                    edgeFlag |= Qt.LeftEdge
                else if (Math.abs(mouseX - width + margin) <= blurSize)
                    edgeFlag |= Qt.RightEdge
                if (Math.abs(mouseY - margin) <= blurSize)
                    edgeFlag |= Qt.TopEdge
                else if (Math.abs(mouseY - height + margin) <= blurSize)
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
        cached: true
        glowRadius: 5
        scale: mainRect.scale
        color: control.palette.shadow
        cornerRadius: glowRadius
    }

    Rectangle {
        id: mainRect
        anchors.centerIn: parent
        width: parent.width - margin * 2
        height: parent.height - margin * 2
        radius: 4
        clip: true
        border {
            width: 1
            color: Qt.darker(effect.color, 1.5)
        }

        Binding {
            when: control.window.visibility === Window.Maximized
            mainRect.border.width: 0
            mainRect.radius: 0
            control.margin: 0
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            // clip elements that are out of background
            cached: true
            maskSource: Rectangle {
                width: mainRect.width
                height: mainRect.height
                radius: mainRect.radius - mainRect.border.width
            }
        }

        TitleBar {
            id: title
            color: "transparent"
            y: mainRect.border.width
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - parent.border.width * 2
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
            control.contentItem.parent: mainRect
            control.contentItem.anchors {
                top: control.menuBar ? control.menuBar.bottom : title.bottom
                left: title.left
                right: title.right
                bottom: mainRect.bottom
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
}

import QtQuick
import QtQuick.Controls

Window {
    id: control
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Window

    enum DragBehavior {
        NoDrag = 0,
        DragTitle,
        DragWindow
    }

    property alias contentItem: bg.contentItem
    property alias background: bg.background
    property alias titleButton: bg.titleButton
    property alias resizable: bg.resizable
    property alias dragBehavior: bg.dragBehavior
    property alias menuBar: bg.menuBar
    property alias title: bg.title

    WindowBackground {
        id: bg
        window: control
        anchors.fill: parent
    }
}

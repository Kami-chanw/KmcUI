import QtQuick
import QtQuick.Controls

Window {
    id: control
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Window

    property alias appIcon: bg.appIcon
    property alias contentItem: bg.contentItem
    property alias background: bg.background
    property alias title: bg.title
    property alias titleButton: bg.titleButton
    property alias resizable: bg.resizable
    property alias dragType: bg.dragType
    property alias menuBar: bg.menuBar

    WindowBackground {
        id: bg
        window: control
        anchors.fill: parent
    }
}

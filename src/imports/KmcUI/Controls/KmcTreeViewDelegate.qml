import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control

    implicitWidth: Math.max(row.implicitWidth,
                            backgroundLoader.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(row.implicitHeight,
                             backgroundLoader.implicitHeight) + topPadding + bottomPadding

    property Component background: Rectangle {
        implicitHeight: 22
        color: selected || hovered ? "lightgray" : "transparent"
    }
    property Component contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        color: selected ? "white" : "black"
        text: currentData
    }
    property Component indicator: Text {
        rotation: expanded ? 90 : 0
        opacity: hasChildren
        text: "▶"
        color: "black"
    }
    property alias spacing: row.spacing
    property int padding: 0
    property int leftPadding: padding
    property int rightPadding: padding
    property int topPadding: padding
    property int bottomPadding: padding

    property var currentIndex
    property var currentData
    property bool expanded
    property int childCount
    property int depth
    property bool hasChildren
    property bool selected
    property bool hovered

    RowLayout {
        id: row
        anchors.fill: parent
        z: 1
        spacing: 3
        Loader {
            id: indicatorLoader
            sourceComponent: control.indicator
            Layout.leftMargin: control.leftPadding
            Layout.topMargin: control.topPadding
            Layout.bottomMargin: control.bottomPadding

            TapHandler {
                onSingleTapped: toggle()
            }
        }
        Loader {
            sourceComponent: contentItem
            Layout.fillWidth: true
            Layout.rightMargin: control.rightPadding
            Layout.topMargin: control.topPadding
            Layout.bottomMargin: control.bottomPaddinge
        }
    }

    Loader {
        id: backgroundLoader
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        TapHandler {
            onSingleTapped: selectCurrent()
            onDoubleTapped: toggle()
        }

        sourceComponent: control.background
        width: row.width + (1 + depth * indentation)
        x: -(depth * indentation)
        z: 0
    }
}

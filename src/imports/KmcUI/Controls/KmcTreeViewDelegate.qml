import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control

    implicitWidth: Math.max(row.implicitWidth, backgroundLoader.implicitWidth)
    implicitHeight: Math.max(row.implicitHeight, backgroundLoader.implicitHeight)

    property Component background: Rectangle {
        implicitHeight: 22
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

    // the following properties will be initialized by KmcTreeView
    property var index
    property var currentData
    property bool expanded
    property int childCount
    property int depth
    property bool hasChildren
    property bool selected
    property bool hovered
    property bool current
    property int indentation: 15

    RowLayout {
        id: row
        anchors.fill: parent
        z: 1
        spacing: 0
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
            onSingleTapped: select()
            onDoubleTapped: toggle()
        }

        sourceComponent: control.background
        width: row.width + (1 + depth * indentation)
        x: -(depth * indentation)
        z: 0
    }
}

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQml 2.15

Flickable {
    id: control

    implicitWidth: 400
    implicitHeight: 400

    property var model
    readonly property alias currentIndex: tree.selectedIndex
    property var currentData
    property alias indentation: tree.indentation

    property alias selectEnabled: tree.selectEnabled
    property alias hoverEnabled: tree.hoverEnabled
    property alias delegate: tree.delegate

    contentHeight: tree.height
    contentWidth: width
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}
    clip: true

    Connections {
        function onCurrentIndexChanged() {
            if (currentIndex)
                currentData = model.data(currentIndex)
        }
    }

    TreeViewItem {
        id: tree
        anchors.fill: parent

        model: control.model
        // if there isn't rootIndex() in model, then create an invalid index as parent index
        parentIndex: model?.rootIndex() ?? model.index(-1, -1)
        childCount: model.rowCount(parentIndex)
        z: 1

        Connections {
            target: control.model
            ignoreUnknownSignals: true
            function onLayoutChanged() {
                tree.childCount = control.model ? control.model.rowCount(tree.parentIndex) : 0
            }
        }
    }
}

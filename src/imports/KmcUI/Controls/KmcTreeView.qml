import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQml

Flickable {
    id: control

    implicitWidth: 400
    implicitHeight: 400

    property var model
    property alias indentation: tree.indentation
    property alias selectedIndexes: selectionModel.selectedIndexes
    property alias pointerNavigationEnabled: tree.pointerNavigationEnabled
    property alias keyNavigationEnabled: tree.keyNavigationEnabled // not implemented yet
    enum SelectionMode {
        NoSelection,
        SingleSelection,
        MultiSelection
    }

    property alias selectionMode: tree.selectionMode
    property alias delegate: tree.delegate

    contentHeight: tree.height
    contentWidth: width
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    TreeViewItem {
        id: tree
        anchors.fill: parent

        model: control.model
        pointerNavigationEnabled: true
        keyNavigationEnabled: true
        selectionMode: KmcTreeView.SingleSelection
        selectionModel: ItemSelectionModel {
            id: selectionModel
            model: control.model
            property var hoveredIndex: null
        }
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

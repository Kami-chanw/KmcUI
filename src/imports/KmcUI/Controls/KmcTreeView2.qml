import QtQuick

TreeView {
    id: control
    enum SelectionMode {
        NoSelection,
        SingleSelection,
        MultiSelection
    }
    property int selectionMode: KmcTreeView2.SingleSelection
    property alias selectedIndexes: selectionModel.selectedIndexes

    selectionModel: ItemSelectionModel {
        id: selectionModel
        model: control.model
    }
}

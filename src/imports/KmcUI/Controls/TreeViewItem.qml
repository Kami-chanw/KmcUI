import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control

    // model properties
    property var model
    property var selectionModel
    property var parentIndex
    property var childCount

    property int selectionMode
    property int indentation: 15
    property int currentIndent: 0
    property bool keyNavigationEnabled
    property bool pointerNavigationEnabled

    implicitHeight: childrenRect.height

    // Components
    property Component delegate: KmcTreeViewDelegate {}

    focus: true
    property bool ctrlPressed: false
    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Control) {
                            ctrlPressed = true
                        }
                    }
    Keys.onReleased: event => {
                         if (event.key === Qt.Key_Control) {
                             ctrlPressed = false
                         }
                     }

    // Body
    ColumnLayout {
        width: parent.width
        spacing: 0

        Repeater {
            id: repeater
            model: childCount
            Layout.fillWidth: true

            delegate: ColumnLayout {
                id: itemColumn
                Layout.leftMargin: control.currentIndent
                spacing: 0

                QtObject {
                    id: props

                    readonly property var currentIndex: control.model.index(index, 0, parentIndex)
                    property var currentData: control.model.data(currentIndex)
                    property bool expanded: false
                    property int childCount: control.model.rowCount(currentIndex)
                    readonly property int depth: getDepth(currentIndex)
                    readonly property bool hasChildren: childCount > 0
                    readonly property bool selected: selectionMode !== KmcTreeView.NoSelection
                                                     && control.selectionModel.selectedIndexes.includes(
                                                         currentIndex)
                    readonly property bool hovered: currentIndex === control.selectionModel.hoveredIndex
                    readonly property bool current: currentIndex === control.selectionModel.currentIndex

                    function getDepth(index) {
                        var count = 0
                        if (index.valid) {
                            for (var anchestor = index; anchestor.parent.valid; anchestor = anchestor.parent)
                                count++
                        }
                        return count
                    }
                }

                Loader {
                    id: delegateLoader

                    Layout.fillWidth: true
                    sourceComponent: control.delegate

                    Instantiator {
                        model: ["indentation", "currentData", "expanded", "childCount", "depth", "hasChildren", "selected", "hovered", "current"]
                        delegate: Binding {
                            target: delegateLoader.item
                            property: modelData
                            value: props[modelData]
                            when: delegateLoader.status === Loader.Ready
                        }
                    }

                    Binding {
                        target: delegateLoader.item
                        property: "index"
                        value: props.currentIndex
                        when: delegateLoader.status === Loader.Ready
                    }

                    function toggle() {
                        if (props.hasChildren)
                            props.expanded = !props.expanded
                    }

                    function select(command = ItemSelectionModel.SelectCurrent) {
                        switch (control.selectionMode) {
                        case KmcTreeView.SingleSelection:
                            command |= ItemSelectionModel.Current
                            break
                        case KmcTreeView.MultiSelection:
                            if (control.ctrlPressed) {
                                command = ItemSelectionModel.Toggle
                            } else {
                                control.selectionModel.clearSelection()
                                command &= ~ItemSelectionModel.Current
                            }
                            break
                        default:
                            return
                        }
                        control.selectionModel.select(props.currentIndex, command)
                        control.selectionModel.setCurrentIndex(props.currentIndex,
                                                               ItemSelectionModel.NoUpdate)
                    }

                    HoverHandler {
                        enabled: control.pointerNavigationEnabled
                        onHoveredChanged: {
                            if (hovered)
                                control.selectionModel.hoveredIndex = props.currentIndex
                        }
                    }
                }

                Loader {
                    id: loader
                    Layout.fillWidth: true

                    visible: props.expanded
                    source: "TreeViewItem.qml"

                    onLoaded: {
                        loader.item.parentIndex = props.currentIndex
                        loader.item.childCount = props.childCount
                    }

                    Instantiator {
                        model: ["model", "selectionMode", "selectionModel", "delegate", "indentation", "ctrlPressed", "keyNavigationEnabled", "pointerNavigationEnabled"]
                        delegate: Binding {
                            target: loader.item
                            property: modelData
                            value: control[modelData]
                            when: loader.status === Loader.Ready
                        }
                    }

                    Binding {
                        target: loader.item
                        property: "currentIndent"
                        value: control.indentation
                        when: loader.status === Loader.Ready
                    }

                    Connections {
                        target: control.model
                        ignoreUnknownSignals: true
                        function onLayoutChanged() {
                            const parent = control.model.index(index, 0, parentIndex)
                            loader.item.childCount = control.model.rowCount(parent)
                            props.childCount = control.model.rowCount(parent)
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control

    // model properties
    property var model
    property var parentIndex
    property var childCount

    property var selectedIndex: null
    property var hoveredIndex: null

    // layout properties
    property bool selectEnabled: true
    property bool hoverEnabled: true

    property int indentation: 15
    property int currentIndent: 0

    implicitHeight: childrenRect.height

    // Components
    property Component delegate: KmcTreeViewDelegate {}

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
                    readonly property bool selected: control.selectEnabled
                                                     && currentIndex === control.selectedIndex
                    readonly property bool hovered: control.hoverEnabled
                                                    && currentIndex === control.hoveredIndex

                    function getDepth(index) {
                        var count = 0
                        if (index.valid) {
                            for (var anchestor = index; anchestor.parent.valid; anchestor = anchestor.parent)
                                count++
                        }
                        return count
                    }
                }

                Connections {
                    target: control.model
                    function onLayoutChanged() {
                        const parent = control.model.index(index, 0, parentIndex)
                        props.childCount = control.model.rowCount(parent)
                    }
                }

                Loader {
                    id: delegateLoader

                    Layout.fillWidth: true
                    sourceComponent: control.delegate
                    readonly property int indentation: control.indentation

                    Instantiator {
                        model: ["currentIndex", "currentData", "expanded", "childCount", "depth", "hasChildren", "selected", "hovered"]
                        delegate: Binding {
                            target: delegateLoader.item
                            property: modelData
                            value: props[modelData]
                            when: delegateLoader.status === Loader.Ready
                        }
                    }

                    function toggle() {
                        if (props.hasChildren)
                            props.expanded = !props.expanded
                    }

                    function selectCurrent() {
                        control.selectedIndex = props.currentIndex
                    }

                    signal hoveredChanged

                    HoverHandler {
                        enabled: control.hoverEnabled
                        onHoveredChanged: {
                            if (hovered && control.hoveredIndex !== props.currentIndex)
                                control.hoveredIndex = props.currentIndex
                            if (!hovered && control.hoveredIndex === props.currentIndex)
                                control.hoveredIndex = null
                            delegateLoader.hoveredChanged()
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
                        model: ["model", "selectedIndex", "delegate", "selectEnabled", "hoverEnabled", "indentation"]
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
                        }
                    }

                    Binding {
                        target: control
                        property: "selectedIndex"
                        value: loader.item.selectedIndex
                        when: loader.status == Loader.Ready
                    }
                }
            }
        }
    }
}

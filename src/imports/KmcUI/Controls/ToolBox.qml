import QtQuick
import QtQuick.Layouts
import QtQuick.Controls


/**
 * The model item must contains string title which means the title of a toolbox
 * If `reorderEnabled` is true, the model must contains function move(from, to, count) to allow ToolBox to move `count` toolboxes from `from` to `to`
 * The property sourceSelector is a function that accept current item and return a jsobject to content loader,
 * and will be used when Loader.loaded emits. The structure of return value is { "source": "source.qml", "properties": {}}
 * You can also use sourceComponentSelector, which also is a function that accept current item but return a Component to  Loader.sourceComponent.
 * For above funcitonalities, the model must contains function get(index)
*/
Flickable {
    id: control
    property Component boxDelegate
    property alias model: repeater.model
    property alias items: repeater
    property Component dropAreaItem: Rectangle {
        color: "#cccccc"
        opacity: 0.15
    }
    property Component dropIndicator: Rectangle {
        color: "#cccccc"
        implicitHeight: 2
    }
    property Transition toggle: Transition {}
    property Component handle: Rectangle {
        color: "#2b2b2b"
        implicitHeight: 1
    }

    property int currentIndex: -1
    property bool reorderEnabled: true
    property bool itemResizable: false
    property var sourceSelector
    property var sourceComponentSelector
    clip: true
    contentHeight: content.height
    contentWidth: content.width
    boundsBehavior: Flickable.StopAtBounds

    signal reordered(int from, int to)

    function setItemSource(index, url, properties) {
        repeater.itemAt(index).contentLoader.setSource(url, properties)
    }

    function setItemSourceComponent(index, comp) {
        repeater.itemAt(index).contentLoader.sourceComponent = comp
    }

    Column {
        id: content
        Repeater {
            id: repeater


            /*
             * When dragging on the top of all the items, targetIndex will be -1,
             * which means -2 should indicate invalid index
            */
            property int targetIndex: -2

            delegate: Item {
                id: boxItem
                width: control.width
                height: column.height

                property alias box: boxLoader.item
                property alias content: contentLoader.item
                property alias contentLoader: contentLoader
                property var expanded: boxLoader.item.expanded
                enabled: boxLoader.item.enabled
                z: dragHandler.active ? 5 : 0
                ShaderEffectSource {
                    id: dragTarget
                    sourceItem: boxLoader
                    height: boxLoader.height
                    width: boxLoader.width
                    property int _index: index
                    opacity: dragHandler.active ? 0.7 : 0
                    anchors.top: parent.top
                    anchors.left: parent.left
                    Drag.active: dragHandler.active
                    Drag.keys: [...Array(repeater.count).keys()].filter(i => i !== index)
                    Drag.hotSpot: Qt.point(mouseArea.mouseX, mouseArea.mouseY)
                    z: dragHandler.active ? 10 : 0
                    states: State {
                        when: dragHandler.active
                        AnchorChanges {
                            target: dragTarget
                            anchors {
                                top: undefined
                                left: undefined
                            }
                        }
                    }
                    DragHandler {
                        id: dragHandler

                        onActiveChanged: {
                            if (!active) {
                                if (control.reorderEnabled) {
                                    if (repeater.targetIndex >= -1) {
                                        const to = Math.max(0, Math.min(repeater.targetIndex,
                                                                        repeater.count - 1))
                                        if (index !== to) {
                                            repeater.model.move(index, to, 1)
                                            control.reordered(index, to)
                                        }
                                    }
                                    repeater.targetIndex = -2
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: !dragHandler.active ? Qt.ArrowCursor : (column.contains(
                                                                                 Qt.point(
                                                                                     dragTarget.x + mouseArea.mouseX,
                                                                                     dragTarget.y + mouseArea.mouseY)) ? Qt.ForbiddenCursor : Qt.DragCopyCursor)
                    }
                }

                Column {
                    id: column

                    Loader {
                        id: boxLoader
                        width: control.width

                        onLoaded: {
                            boxLoader.item.index = Qt.binding(() => index)
                            boxLoader.item.content = Qt.binding(() => contentLoader.item)
                            boxLoader.item.model = repeater.model.get(index)
                            boxLoader.item.highlighted = Qt.binding(
                                        () => control.currentIndex === index)
                            contentLoader.updateSource()
                        }

                        function forceHighlight() {
                            control.currentIndex = index
                        }

                        Connections {
                            target: repeater.model
                            function onDataChanged(leftTop) {
                                if (leftTop.row === index) {
                                    boxLoader.item.model = repeater.model.get(index)
                                    contentLoader.updateSource()
                                }
                            }
                        }

                        sourceComponent: control.boxDelegate
                    }

                    Loader {
                        id: contentLoader
                        clip: true
                        function updateSource() {
                            if (control.sourceComponentSelector) {
                                contentLoader.sourceComponent = control.sourceComponentSelector(
                                            index)
                            } else if (control.sourceSelector) {
                                const param = control.sourceSelector(index)
                                contentLoader.setSource(param["source"], param["properties"])
                            } else
                                throw new Error("KmcUI.Controls.ToolBox: One of properties sourceComponentSelector and sourceComponent should be initialized.")
                        }

                        width: control.width

                        states: State {
                            when: !boxItem.expanded && contentLoader.status === Loader.Ready
                            PropertyChanges {
                                contentLoader.height: 0
                            }
                        }

                        transitions: control.toggle
                    }
                    Loader {
                        width: control.width
                        sourceComponent: control.handle
                    }
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent

                    keys: [index]

                    Loader {
                        width: parent.width
                        height: boxItem.expanded ? parent.height / 2 : parent.height
                        y: boxItem.expanded
                           && dropArea.drag.y >= parent.height / 2 ? parent.height / 2 : 0
                        active: dropArea.containsDrag && control.reorderEnabled
                        sourceComponent: control.dropAreaItem

                        property bool containsDrag: dropArea.containsDrag
                    }
                    Loader {
                        y: dropArea.drag.y < boxLoader.height / 2 ? 0 : boxLoader.height - height
                        width: parent.width
                        active: dropArea.containsDrag && !boxItem.expanded && control.reorderEnabled
                        sourceComponent: control.dropIndicator
                    }

                    onPositionChanged: drag => {
                                           repeater.targetIndex = dropArea.drag.y < boxItem.height
                                           / 2 ? index - 1 : index // move down
                                           if (index < drag.source._index) {
                                               // move up
                                               repeater.targetIndex++
                                           }
                                       }
                }
            }
        }
    }
}

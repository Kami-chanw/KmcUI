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
    property Component dropAreaItem
    property Component dropIndicator: Rectangle {
        color: "#cccccc"
        implicitHeight: 2
    }
    property int currentIndex: -1
    property bool reorderEnabled: true
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

                property alias contentLoader: contentLoader
                property bool expanded: false
                Column {
                    id: column
                    Loader {
                        id: boxLoader
                        width: control.width

                        onLoaded: {
                            boxLoader.item.expanded = Qt.binding(() => boxItem.expanded)
                            boxLoader.item.highlighted = Qt.binding(
                                        () => control.currentIndex === index)
                            boxLoader.item.model = Qt.binding(() => repeater.model.get(index))
                        }

                        sourceComponent: control.boxDelegate
                    }

                    Loader {
                        id: contentLoader

                        Component.onCompleted: {
                            if (control.sourceComponentSelector !== undefined) {
                                contentLoader.sourceComponent = control.sourceComponentSelector(
                                            index)
                            } else if (control.sourceSelector !== undefined) {
                                const param = control.sourceSelector(index)
                                contentLoader.setSource(param["source"], param["properties"])
                            } else
                                throw new Error("KmcUI.Controls.ToolBox: One of properties sourceComponentSelector and sourceComponent should be initialized.")
                        }

                        width: control.width
                        Binding {
                            when: !boxItem.expanded && contentLoader.status === Loader.Ready
                            target: contentLoader
                            property: "height"
                            value: 0
                        }

                        Behavior on height {
                            enabled: contentLoader.status === Loader.Ready
                            NumberAnimation {
                                id: collapseAnim
                                easing.type: Easing.InOutQuad
                            }
                        }
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

                z: mouseArea.drag.active ? 1 : 0
                Loader {
                    id: dragTarget
                    active: control.reorderEnabled
                    onLoaded: {
                        dragTarget.item.expanded = Qt.binding(() => boxItem.expanded)
                    }
                    property int _index: index
                    opacity: 0.7
                    anchors.top: parent.top
                    anchors.left: parent.left
                    Drag.active: mouseArea.drag.active
                    Drag.keys: [...Array(repeater.count).keys()].filter(i => i !== index)
                    Drag.hotSpot: Qt.point(mouseArea.mouseX, mouseArea.mouseY)
                    states: State {
                        when: mouseArea.drag.active
                        AnchorChanges {
                            target: dragTarget
                            anchors {
                                top: undefined
                                left: undefined
                            }
                        }
                    }

                    width: boxLoader.width
                    height: boxLoader.height
                    sourceComponent: control.boxDelegate
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        drag.target: dragTarget
                        hoverEnabled: true
                        z: 1
                        cursorShape: !drag.active ? Qt.ArrowCursor : (boxLoader.contains(
                                                                          Qt.point(
                                                                              dragTarget.x + mouseX,
                                                                              dragTarget.y + mouseY)) ? Qt.ForbiddenCursor : Qt.DragCopyCursor)

                        onReleased: {
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
                        onClicked: {
                            if (!collapseAnim.running && boxLoader.contains(
                                        Qt.point(mouseArea.mouseX, mouseArea.mouseY))) {
                                boxItem.expanded = !boxItem.expanded
                                control.currentIndex = index
                            }
                        }
                    }
                }
            }
        }
    }
}

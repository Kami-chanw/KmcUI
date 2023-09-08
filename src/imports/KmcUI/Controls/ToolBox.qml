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
ScrollView {
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

    signal reordered(int from, int to)

    function setItemSource(index, url, properties) {
        repeater.itemAt(index).contentLoader.setSource(url, properties)
    }

    function setItemSourceComponent(index, comp) {
        repeater.itemAt(index).contentLoader.sourceComponent = comp
    }

    Column {
        anchors.fill: parent
        Repeater {
            id: repeater


            /*
             * When dragging on the top of all the items, targetIndex will be -1,
             * which means -2 should indicate invalid index
            */
            property int targetIndex: -2

            delegate: Item {
                id: boxItem
                width: control.implicitWidth
                height: column.height
                z: mouseArea.drag.active ? 2 : 0
                //                property alias contentLoader: contentLoader
                Column {
                    id: column
                    Loader {
                        id: boxLoader
                        property var model: repeater.model.get(index)
                        property bool expanded: false
                        width: control.implicitWidth
                        Binding {
                            target: boxLoader.item
                            property: "highlighted"
                            value: control.currentIndex === index
                            when: boxLoader.status === Loader.Ready
                        }
                        //                        Binding {
                        //                            target: boxLoader.item
                        //                            property: "model"
                        //                            value: repeater.model.get(index)
                        //                            when: boxLoader.status === Loader.Ready
                        //                        }
                        sourceComponent: control.boxDelegate
                    }

                    Loader {
                        id: contentLoader

                        onLoaded: {
                            console.log("MyToolBox")
                            if (control.sourceComponentSelector !== undefined) {
                                contentLoader.sourceComponent = control.sourceComponentSelector(index)
                            } else if (control.sourceSelector !== undefined) {
                                const param = control.sourceSelector(index)
                                contentLoader.setSource(param["source"], param["properties"])
                            } else
                                throw new Error("KmcUI.Controls.ToolBox: One of properties sourceComponentSelector and sourceComponent should be initialized.")
                        }

                        width: control.implicitWidth
                        Binding {
                            when: !boxLoader.expanded && boxLoader.status === Loader.Ready
                            target: contentLoader
                            property: "height"
                            value: 0
                        }

                        Behavior on height {
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
                        height: boxLoader.expanded ? parent.height / 2 : parent.height
                        y: boxLoader.expanded
                           && dropArea.drag.y >= parent.height / 2 ? parent.height / 2 : 0
                        active: dropArea.containsDrag && control.reorderEnabled
                        sourceComponent: control.dropAreaItem

                        property bool containsDrag: dropArea.containsDrag
                    }
                    Loader {
                        y: dropArea.drag.y < boxLoader.height / 2 ? 0 : boxLoader.height - height
                        width: parent.width
                        active: dropArea.containsDrag && !boxLoader.expanded
                                && control.reorderEnabled
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

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    drag.target: dragTarget
                    onReleased: {
                        if (control.reorderEnabled) {
                            if (repeater.targetIndex >= -1) {
                                const to = Math.max(0, Math.min(repeater.targetIndex,
                                                                repeater.count - 1))
                                repeater.model.move(index, to, 1)
                                control.reordered.emit(index, to)
                            }
                            repeater.targetIndex = -2
                        }
                    }

                    onClicked: {
                        if (!collapseAnim.running && boxLoader.contains(Qt.point(mouseX, mouseY))) {
                            boxLoader.expanded = !boxLoader.expanded
                            control.currentIndex = index
                        }
                    }

                    Loader {
                        id: dragTarget
                        visible: mouseArea.drag.active
                        active: control.reorderEnabled
                        property string title: model.title
                        property bool expanded: false
                        property int _index: index
                        opacity: 0.7
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                        }
                        Drag.active: mouseArea.drag.active
                        Drag.keys: [...Array(repeater.count).keys()].filter(i => i !== index)
                        states: State {
                            when: mouseArea.drag.active
                            AnchorChanges {
                                target: dragTarget
                                anchors {
                                    verticalCenter: undefined
                                    horizontalCenter: undefined
                                }
                            }
                            PropertyChanges {
                                dragTarget.x: mouseArea.mouseX
                                dragTarget.y: mouseArea.mouseY
                            }
                        }

                        width: boxLoader.width
                        height: boxLoader.height
                        sourceComponent: control.boxDelegate
                    }
                }
            }
        }
    }
}

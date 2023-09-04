import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ScrollView {
    id: control
    //    highlightFollowsCurrentItem: false
    property Component boxDelegate
    property alias model: repeater.model
    property Component dropAreaItem
    property Component dropIndicator: Rectangle {
        color: "#cccccc"
        implicitHeight: 2
    }
    property int currentIndex: -1

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
                Column {
                    id: column
                    Loader {
                        id: boxLoader
                        property string title: model.title
                        property bool expanded: false
                        width: control.implicitWidth
                        Binding {
                            target: boxLoader.item
                            property: "highlighted"
                            value: control.currentIndex === index
                            when: boxLoader.status === Loader.Ready
                        }
                        sourceComponent: control.boxDelegate
                    }

                    Loader {
                        id: contentLoader
                        sourceComponent: model.content()
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
                        active: dropArea.containsDrag
                        sourceComponent: control.dropAreaItem

                        property bool containsDrag: dropArea.containsDrag
                    }
                    Loader {
                        y: dropArea.drag.y < boxLoader.height / 2 ? 0 : boxLoader.height - height
                        width: parent.width
                        active: dropArea.containsDrag && !boxLoader.expanded
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
                        if (repeater.targetIndex >= -1)
                            repeater.model.move(index, Math.max(0, Math.min(repeater.targetIndex,
                                                                            repeater.count - 1)), 1)
                        repeater.targetIndex = -2
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

                        HoverHandler {
                            cursorShape: Qt.ForbiddenCursor
                        }
                    }
                }
            }
        }
    }
}

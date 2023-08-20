import QtQuick
import QtQuick.Controls
import KmcUI

ListView {
    id: control

    component ItemAnimData: QtObject {
        property int inDuration
        property int outDuration: inDuration
        property color iconColor
        property color buttonColor
        property color textColor
    }

    property font font: Qt.font({
                                    "pointSize": 9
                                })
    required property int size
    property bool toggleEnabled: true
    property int location: KmcUI.Left
    onLocationChanged: {
        if (location === KmcUI.Left || location === KmcUI.Right)
            orientation = Qt.Vertical
        else
            orientation = Qt.Horizontal
    }

    palette {
        button: "transparent"
    }
    property ItemAnimData hover: ItemAnimData {
        inDuration: 60
        outDuration: 120
        iconColor: control.icons.color
        buttonColor: control.palette.button
        textColor: control.palette.buttonText
    }
    property ItemAnimData active: ItemAnimData {
        inDuration: 10
        iconColor: control.icons.color
        buttonColor: control.palette.button
        textColor: control.palette.buttonText
    }
    property IconData icons: IconData {
        width: 13
        height: width
        color: "#212121"
    }

    property Component toolTip: undefined

    signal aboutToSwitch(int currentIndex, int nextIndex)

    Binding {
        when: control.location === KmcUI.Left
        control {
            anchors {
                left: control.parent.left
                top: control.layoutDirection === Qt.LeftToRight ? control.parent.top : undefined
                bottom: control.layoutDirection === Qt.RightToLeft ? control.parent.bottom : undefined
            }
            height: control.count * control.size
        }
    }
    Binding {
        when: control.location === KmcUI.Right
        control {
            anchors {
                right: control.parent.right
                top: control.layoutDirection === Qt.LeftToRight ? control.parent.top : undefined
                bottom: control.layoutDirection === Qt.RightToLeft ? control.parent.bottom : undefined
            }
            height: control.count * control.size
        }
    }
    Binding {
        when: control.location === KmcUI.Top
        control {
            anchors {
                left: control.layoutDirection === Qt.LeftToRight ? control.parent.left : undefined
                right: control.layoutDirection === Qt.RightToLeft ? control.parent.right : undefined
                top: control.parent.top
            }
            width: control.count * control.size
        }
    }
    Binding {
        when: control.location === KmcUI.Bottom
        control {
            anchors {
                left: control.layoutDirection === Qt.LeftToRight ? control.parent.left : undefined
                right: control.layoutDirection === Qt.RightToLeft ? control.parent.right : undefined
                top: control.parent.top
            }
            width: control.count * control.size
        }
    }

    highlight: Item {
        Rectangle {
            id: indicator
            anchors {
                left: control.location !== KmcUI.Right ? parent.left : undefined
                top: control.location !== KmcUI.Bottom ? parent.top : undefined
                bottom: control.location !== KmcUI.Top ? parent.bottom : undefined
                right: control.location !== KmcUI.Left ? parent.right : undefined
            }
            color: "#0078D4"

            Binding {
                when: control.orientation === Qt.Vertical
                indicator.width: 1
            }

            Binding {
                when: control.orientation === Qt.Horizontal
                indicator.height: 1
            }
        }
    }

    delegate: Component {
        Rectangle {
            id: item
            color: control.palette.button
            height: control.orientation === ListView.Horizontal ? control.height : control.size
            width: control.orientation === ListView.Horizontal ? control.size : control.width
            property alias itemText: itemText
            property alias icon: itemIcon
            property alias enabled: itemMouseArea.enabled

            property string name: model.name
            property ItemAnimData hover: ItemAnimData {
                inDuration: control.hover.inDuration
                outDuration: control.hover.outDuration


                /* The real logic is as follows
                if (items.hover.iconColor !== items.icons.color)
                    return items.hover.iconColor
                if (itemIcon.item.color !== items.icons.color)
                    return itemIcon.item.color
                return items.icons.color
                */
                iconColor: control.hover.iconColor !== control.icons.color ? control.hover.iconColor : itemIcon.color
                buttonColor: item.color != control.palette.button ? item.color : control.hover.buttonColor
                textColor: control.hover.textColor
                           != control.palette.buttonText ? control.hover.textColor : itemText.color
            }

            property ItemAnimData active: ItemAnimData {
                inDuration: control.active.inDuration
                outDuration: control.active.outDuration
                iconColor: control.hover.iconColor !== control.icons.color ? control.hover.iconColor : itemIcon.color
                buttonColor: item.color != control.palette.button ? item.color : control.hover.buttonColor
                textColor: control.hover.textColor
                           != control.palette.buttonText ? control.hover.textColor : itemText.color
            }

            Loader {
                id: itemToolTip
                active: control.toolTip !== undefined
                sourceComponent: control.toolTip
                onLoaded: {
                    itemToolTip.item.parent = item
                    itemToolTip.item.visible = Qt.binding(() => itemMouseArea.containsMouse)
                }

                Binding {
                    target: itemToolTip.item
                    property: "text"
                    value: model.tooltip
                    when: itemToolTip.status === Loader.Ready
                }
            }

            Column {
                id: itemLayout
                anchors.centerIn: parent
                spacing: 3
                ColorIcon {
                    id: itemIcon
                    visible: Boolean(model.icon)
                    width: control.icons.width
                    height: control.icons.height
                    source: model.icon
                    color: control.icons.color
                }
                Text {
                    id: itemText
                    text: model.text ?? ""
                    font: control.font
                    color: control.palette.buttonText
                }
            }

            states: [
                State {
                    name: "hover"
                    when: itemMouseArea.containsMouse
                    PropertyChanges {
                        item.color: item.hover.buttonColor
                        itemIcon.color: item.hover.iconColor
                        itemText.color: item.hover.textColor
                    }
                },
                State {
                    name: "active"
                    when: control.currentIndex === index
                    PropertyChanges {
                        item.color: item.active.buttonColor
                        itemIcon.color: item.active.iconColor
                        itemText.color: item.active.textColor
                    }
                }
            ]

            transitions: [
                Transition {
                    from: ""
                    to: "hover"
                    ColorAnimation {
                        duration: item.hover.inDuration
                    }
                },
                Transition {
                    from: "hover"
                    to: ""
                    ColorAnimation {
                        duration: item.hover.outDuration
                    }
                },
                Transition {
                    to: "active"
                    ColorAnimation {
                        duration: item.active.inDuration
                    }
                },
                Transition {
                    from: "active"
                    ColorAnimation {
                        duration: item.active.outDuration
                    }
                }
            ]

            Shortcut {
                id: itemShortcut
                enabled: model.shortcut !== undefined
                sequence: model.shortcut

                onActivated: itemMouseArea.switchIndex()
            }

            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                hoverEnabled: true

                function switchIndex() {
                    if (control.currentIndex !== index) {
                        control.aboutToSwitch(control.currentIndex, index)
                        control.model.get(control.currentIndex)?.deactivate(index)
                        control.currentIndex = index
                        model?.activate(control.currentIndex)
                    } else if (toggleEnabled) {
                        control.aboutToSwitch(control.currentIndex, -1)
                        control.model.get(control.currentIndex)?.deactivate(-1)
                        control.currentIndex = -1
                    }
                }

                onClicked: switchIndex()
            }
        }
    }
}

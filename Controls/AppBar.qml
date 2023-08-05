import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import KmcUI

GridLayout {
    id: control
    flow: isHorizontal() ? GridLayout.LeftToRight : GridLayout.TopToBottom
    layoutDirection: control.direction === AppBar.LeftToRight
                     || control.direction === AppBar.TopToBottom ? Qt.LeftToRight : Qt.RightToLeft
    columnSpacing: 0
    rowSpacing: 0

    function isHorizontal() {
        return direction === AppBar.LeftToRight || direction === AppBar.RightToLeft
    }

    enum Direction {
        LeftToRight = 10,
        RightToLeft = 11,
        TopToBottom = 12,
        BottomToTop = 13
    }

    function addItemAt(index, name, icon, text, tooltip, shortcut, onClicked) {
        var object = {
            "name": name
        }
        if (icon)
            object["icon"] = icon
        if (text)
            object["text"] = text
        if (tooltip)
            object["tooltip"] = tooltip
        if (shortcut)
            object["shortcut"] = shortcut
        if (onClicked)
            object["onClicked"] = onClicked
        items.model.insert(index, object)
        return items.itemAt(index)
    }

    function appendItem(name, icon, text, tooltip, shortcut, onClicked) {
        return addItemAt(items.model.count, name, icon, text, tooltip, shortcut, onClicked)
    }

    function itemAt(index) {
        return items.itemAt(index)
    }

    function itemByName(name) {
        for (var i = 0; i < items.count; ++i) {
            var b = items.itemAt(i)
            if (b.name === name)
                return b
        }
    }

    function moveItem(from, to) {
        items.model.move(from, to, 1)
    }

    property Item indicator: Rectangle {
        color: items.icons.color
        implicitHeight: 1
        implicitWidth: 1
    }

    property int direction: location === KmcUI.Left
                            || location === KmcUI.Right ? AppBar.TopToBottom : AppBar.LeftToRight
    required property int location
    property alias model: items.model
    property int currentIndex: -1
    property alias items: items
    property bool toggleEnabled: true

    palette {
        button: "transparent"
    }

    onLocationChanged: {
        if (((location === KmcUI.Left || location === KmcUI.Right) && isHorizontal())
                || ((location === KmcUI.Top || location === KmcUI.Bottom) && !isHorizontal())) {
            console.warn("KmcUI.AppBar: The indicator's location and direction are incompatible")
            indicator.visible = false
        }
    }

    Binding {
        when: control.location === KmcUI.Left
        control {
            indicator {
                anchors.left: indicator.parent !== control ? indicator.parent.left : undefined
                width: indicator.implicitWidth
                height: items.size
            }
            anchors {
                left: control.parent.left
                top: control.direction === AppBar.TopToBottom ? control.parent.top : undefined
                bottom: control.direction === AppBar.BottomTopTop ? control.parent.bottom : undefined
            }
            height: items.height
        }
    }
    Binding {
        when: control.location === KmcUI.Right
        control {
            indicator {
                anchors.right: indicator.parent !== control ? indicator.parent.right : undefined
                width: indicator.implicitWidth
                height: items.size
            }
            anchors {
                right: control.parent.right
                top: control.direction === AppBar.TopToBottom ? control.parent.top : undefined
                bottom: control.direction === AppBar.BottomTopTop ? control.parent.bottom : undefined
            }
            height: items.height
        }
    }
    Binding {
        when: control.location === KmcUI.Top
        control {
            indicator {
                anchors.top: indicator.parent !== control ? indicator.parent.top : undefined
                height: indicator.implicitHeight
                width: items.size
            }
            anchors {
                left: control.direction === AppBar.LeftToRight ? control.parent.left : undefined
                right: control.direction === AppBar.RightToLeft ? control.parent.right : undefined
                top: control.parent.top
            }
            width: items.width
        }
    }
    Binding {
        when: control.location === KmcUI.Bottom
        control {
            indicator {
                anchors.bottom: indicator.parent !== control ? indicator.parent.bottom : undefined
                height: indicator.implicitHeight
                width: items.size
            }
            anchors {
                left: control.direction === AppBar.LeftToRight ? control.parent.left : undefined
                right: control.direction === AppBar.RightToLeft ? control.parent.right : undefined
                top: control.parent.top
            }
            width: items.width
        }
    }

    Binding {
        control.indicator {
            parent: control.indicator.visible ? items.itemAt(control.currentIndex) : control
            visible: 0 <= control.currentIndex && control.currentIndex < items.count
        }
    }

    component ItemAnimData: QtObject {
        property int inDuration
        property int outDuration: inDuration
        property color iconColor
        property color buttonColor
        property color textColor
    }

    component AppBarItems: Repeater {
        id: _items

        property font font: Qt.font({
                                        "pointSize": 9
                                    })
        required property int size
        property ItemAnimData hover: ItemAnimData {
            inDuration: 60
            outDuration: 120
            iconColor: _items.icons.color
            buttonColor: control.palette.button
            textColor: control.palette.buttonText
        }
        property ItemAnimData active: ItemAnimData {
            inDuration: 10
            iconColor: _items.icons.color
            buttonColor: control.palette.button
            textColor: control.palette.buttonText
        }
        property IconData icons: IconData {
            width: 13
            height: width
            color: "#212121"
        }

        property var toolTip: undefined

        delegate: Component {
            Rectangle {
                id: item
                color: control.palette.button
                height: isHorizontal() ? control.height : _items.size
                width: isHorizontal() ? _items.size : control.width
                property alias itemText: itemText
                property alias icon: itemIcon
                property alias enabled: itemMouseArea.enabled
                readonly property bool isActive: control.currentIndex === index

                property string name: model.name
                property ItemAnimData hover: ItemAnimData {
                    inDuration: _items.hover.inDuration
                    outDuration: _items.hover.outDuration


                    /* The real logic is as follows
                    if (items.hover.iconColor !== items.icons.color)
                        return items.hover.iconColor
                    if (itemIcon.item.color !== items.icons.color)
                        return itemIcon.item.color
                    return items.icons.color
                    */
                    iconColor: _items.hover.iconColor !== _items.icons.color ? _items.hover.iconColor : itemIcon.color

                    buttonColor: item.color != control.palette.button ? item.color : _items.hover.buttonColor
                    textColor: _items.hover.textColor
                               != control.palette.buttonText ? _items.hover.textColor : itemText.color
                }

                property ItemAnimData active: ItemAnimData {
                    inDuration: _items.active.inDuration
                    outDuration: _items.active.outDuration
                    iconColor: _items.hover.iconColor !== _items.icons.color ? _items.hover.iconColor : itemIcon.color

                    buttonColor: item.color != control.palette.button ? item.color : _items.hover.buttonColor
                    textColor: _items.hover.textColor
                               != control.palette.buttonText ? _items.hover.textColor : itemText.color
                }

                Column {
                    id: itemLayout
                    anchors.centerIn: parent
                    spacing: 3
                    ColorIcon {
                        id: itemIcon
                        visible: Boolean(model.icon)
                        width: _items.icons.width
                        height: _items.icons.height
                        source: model.icon
                        color: _items.icons.color
                    }
                    Text {
                        id: itemText
                        text: model.text ?? ""
                        font: _items.font
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
                        when: isActive
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
                        _items.model.get(control.currentIndex)?.deactivate(index)
                        model?.activate(control.currentIndex)
                        control.currentIndex = toggleEnabled && currentIndex === index ? -1 : index
                    }

                    onClicked: switchIndex()
                    onContainsMouseChanged: {
                        if (_items.toolTip) {
                            if (containsMouse) {
                                _items.toolTip.parent = item
                                _items.toolTip.text = model.tooltip
                            }
                            _items.toolTip.visible = containsMouse
                        }
                    }
                }
            }
        }
    }

    AppBarItems {
        id: items
    }
}

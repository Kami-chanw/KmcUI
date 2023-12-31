﻿import QtQuick
import KmcUI

KmcRectangle {
    id: control

    enum TitleButton {
        Close = 1,
        Minimize = 2,
        Maximize = 4,
        Full = 7
    }

    property Window window
    property bool buttonEnabled: true
    property alias buttons: _buttons
    property int titleButton: TitleBar.TitleButton.Close

    palette {
        button: "transparent"
    }

    ListModel {
        id: buttonModel
        ListElement {
            name: "Minimize"
            icon: "qrc:/assets/icons/minimize.svg"
            tooltip: qsTr("最小化")
            onClicked: () => window?.showMinimized()
        }

        ListElement {
            name: "Maximize"
            icon: "qrc:/assets/icons/maximize.svg"
            tooltip: qsTr("最大化")
            onClicked: () => {
                           if (window.visibility === Window.Maximized) {
                               window?.showNormal()
                           } else {
                               window?.showMaximized()
                           }
                       }
        }

        ListElement {
            name: "Close"
            icon: "qrc:/assets/icons/close.svg"
            tooltip: qsTr("关闭")
            onClicked: () => window?.close()
        }
    }

    function addButtonAt(index, name, icon, tooltip, onClicked) {
        let visibleCount = 0
        for (var i = 0; i < buttonModel.count && visibleCount < index; i++) {
            const item = buttonModel.get(i)
            if (item.visible) {
                visibleCount++
            }
        }

        buttonModel.insert(i, {
                               "name": name,
                               "icon": icon,
                               "tooltip": tooltip,
                               "onClicked": onClicked
                           })
        return buttons.itemAt(i)
    }

    function appendButton(name, icon, tooltip, onClicked) {
        for (var i = buttonModel.count - 1; i >= 0; i--) {
            const item = buttonModel.get(i)
            if (item.visible)
                break
        }

        buttonModel.insert(i + 1, {
                               "name": name,
                               "icon": icon,
                               "tooltip": tooltip,
                               "onClicked": onClicked
                           })
        return buttons.itemAt(i + 1)
    }

    function buttonAt(index) {
        let visibleCount = -1
        for (var i = 0; visibleCount < index && i < buttonModel.count; i++) {
            const item = buttonModel.get(i)
            if (item.visible) {
                visibleCount++
            }
        }
        return buttons.itemAt(i)
    }

    function buttonByName(name) {
        for (var i = 0; i < buttonModel.count; ++i) {
            const b = buttons.itemAt(i)
            if (b.name === name)
                return b
        }
    }

    function moveButton(from, to) {
        buttonModel.move(from, to, 1)
    }

    component ButtonAnimData: QtObject {
        property int inDuration
        property int outDuration: inDuration
        property color iconColor
        property color buttonColor
    }

    component TitleBarButtons: Repeater {
        id: buttons
        property int buttonWidth: control.height
        property int buttonHeight: control.height
        property IconData icons: IconData {
            width: 13
            height: width
            color: "#212121"
        }

        property ButtonAnimData hover: ButtonAnimData {
            inDuration: 60
            outDuration: 120
            iconColor: buttons.icons.color
            buttonColor: control.palette.button
        }
        property ButtonAnimData press: ButtonAnimData {
            inDuration: 10
            iconColor: buttons.icons.color
            buttonColor: control.palette.button
        }
        property Component toolTip: Component {
            WndMouseToolTip {
                horizontalPadding: 5
                verticalPadding: 2
            }
        }

        model: buttonModel

        delegate: Component {
            Rectangle {
                id: button
                width: buttons.buttonWidth
                height: buttons.buttonHeight
                color: control.palette.button

                property alias icon: titleButtonIcon
                property alias enabled: titleButtonMouseArea.enabled
                property string name: model.name
                property string tooltip: model.tooltip
                property ButtonAnimData hover: ButtonAnimData {
                    inDuration: buttons.hover.inDuration
                    outDuration: buttons.hover.outDuration


                    /* The real logic is as follows
                    // select a suitable default color
                    if (buttons.icons.color !== buttons.hover.iconColor)
                        // if buttons.hover.iconColor is not default
                        return buttons.hover.iconColor
                    if (titleButtonIcon.color !== buttons.icons.color)
                        // if buttons.hover.iconColor is not specified and current icon color is not default
                        return titleButtonIcon.color
                    return buttons.icons.color
                    */
                    iconColor: buttons.icons.color
                               !== buttons.hover.iconColor ? buttons.hover.iconColor : titleButtonIcon.color
                    buttonColor: control.palette.button
                                 != buttons.hover.buttonColor ? buttons.hover.buttonColor : button.color
                }

                property ButtonAnimData press: ButtonAnimData {
                    inDuration: buttons.press.inDuration
                    outDuration: buttons.press.outDuration
                    iconColor: buttons.icons.color
                               !== buttons.press.iconColor ? buttons.press.iconColor : button.hover.iconColor
                    buttonColor: control.palette.button
                                 != buttons.press.buttonColor ? buttons.press.buttonColor : button.hover.buttonColor
                }

                ColorIcon {
                    id: titleButtonIcon
                    anchors.centerIn: parent
                    width: buttons.icons.width
                    height: buttons.icons.height
                    source: model.icon
                    color: titleButtonMouseArea.enabled ? buttons.icons.color : control.palette.disabled.button
                }

                Loader {
                    id: titleButtonToolTip
                    sourceComponent: buttons.toolTip
                    onLoaded: {
                        titleButtonToolTip.item.parent = button
                        titleButtonToolTip.item.visible = Qt.binding(
                                    () => titleButtonMouseArea.containsMouse)
                    }
                    Binding {
                        target: titleButtonToolTip.item
                        property: "text"
                        value: button.tooltip
                        when: titleButtonToolTip.status === Loader.Ready
                    }
                }

                states: [
                    State {
                        name: "hover"
                        when: titleButtonMouseArea.containsMouse && !titleButtonMouseArea.pressed
                        PropertyChanges {
                            button.color: button.hover.buttonColor
                            titleButtonIcon.color: button.hover.iconColor
                        }
                    },
                    State {
                        name: "press"
                        when: titleButtonMouseArea.containsPress
                        PropertyChanges {
                            button.color: button.press.buttonColor
                            titleButtonIcon.color: button.press.iconColor
                        }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""
                        to: "hover"
                        ColorAnimation {
                            duration: button.hover.inDuration
                        }
                    },
                    Transition {
                        from: "hover"
                        to: ""
                        ColorAnimation {
                            duration: button.hover.outDuration
                        }
                    },
                    Transition {
                        from: "hover"
                        to: "press"
                        ColorAnimation {
                            duration: button.press.inDuration
                        }
                    },
                    Transition {
                        from: "press"
                        to: "hover"
                        ColorAnimation {
                            duration: button.press.outDuration
                        }
                    }
                ]

                MouseArea {
                    id: titleButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: model.onClicked()

                    Binding {
                        when: !control.buttonEnabled
                        titleButtonMouseArea.enabled: false
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // find window if it isn't set explicitly
        for (var p = parent; p && !window; p = p.parent) {
            if (p instanceof Window)
                window = p
            else if (p.window)
                window = p.window
        }

        let minimizeButton = buttonByName("Minimize")
        let maximizeButton = buttonByName("Maximize")
        let closeButton = buttonByName("Close")
        minimizeButton.visible = titleButton & TitleBar.TitleButton.Minimize
        maximizeButton.visible = titleButton & TitleBar.TitleButton.Maximize
        closeButton.visible = titleButton & TitleBar.TitleButton.Close
        if (window) {
            maximizeButton.icon.source = Qt.binding(
                        () => window.visibility
                        === Window.Maximized ? "qrc:/assets/icons/restore.svg" : "qrc:/assets/icons/maximize.svg")
            maximizeButton.tooltip = Qt.binding(
                        () => window.visibility === Window.Maximized ? qsTr("还原") : qsTr("最大化"))
        }
    }

    Row {
        spacing: 1
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        TitleBarButtons {
            id: _buttons
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.ToolTip {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)
    margins: 6
    padding: 6

    property int cursorSize: 16
    property MouseArea mouseArea
    readonly property bool mouseAreaEnabled: mouseArea?.enabled ?? false

    onParentChanged: {
        for (var p = parent; p; p = p.parent) {
            for (var i = 0; i < p.children.length; ++i) {
                if (p.children[i] instanceof MouseArea) {
                    mouseArea = p.children[i]
                    return
                }
            }
        }
    }

    onAboutToShow: {
        x = mouseArea.mouseX
        y = mouseArea.mouseY + cursorSize
    }

    onMouseAreaEnabledChanged: close()

    enter: Transition {
        NumberAnimation {
            target: control
            property: "opacity"
            duration: 80
            from: 0
            to: 1
        }
    }

    contentItem: Text {
        id: text
        wrapMode: Text.Wrap
        text: control.text
        color: control.palette.toolTipText
    }

}

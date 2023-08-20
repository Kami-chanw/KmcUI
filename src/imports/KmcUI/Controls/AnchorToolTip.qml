import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import KmcUI

T.ToolTip {
    id: control

    property int location: KmcUI.Bottom // note that it's just an advice, ToolTip never exceeds its parent
    property int distance: 3
    property alias fadeOutDuration: fadeAnim.duration
    property alias fadeInDuration: scaleAnim.duration
    delay: 1000
    timeout: 9000

    x: {
        if (parent) {
            switch (location) {
            case KmcUI.Left:
                return -width - distance
            case KmcUI.Right:
                return parent.width + distance
            case KmcUI.Top:
            case KmcUI.Bottom:
                return (parent.width - width) / 2
            }
        }
        return 0
    }
    y: {
        switch (location) {
        case KmcUI.Left:
        case KmcUI.Right:
            return (parent.height - height) / 2
        case KmcUI.Top:
            return -height - distance
        case KmcUI.Bottom:
            return parent.height + distance
        }
        return 0
    }

    width: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                    contentWidth + leftPadding + rightPadding)
    height: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                     contentHeight + topPadding + bottomPadding)

    margins: 6
    padding: 6

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    transformOrigin: {
        switch (location) {
        case KmcUI.Left:
            return Popup.Right
        case KmcUI.Right:
            return Popup.Left
        case KmcUI.Top:
            return Popup.Bottom
        case KmcUI.Bottom:
            return Popup.Top
        }
    }

    contentItem: Text {
        id: text
        wrapMode: Text.Wrap
        text: control.text
        color: control.palette.toolTipText
    }

    enter: Transition {
        NumberAnimation {
            id: scaleAnim
            target: control
            properties: "scale,opacity"
            from: 0.5
            to: 1
            duration: 100
        }
    }

    exit: Transition {
        NumberAnimation {
            id: fadeAnim
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 100
        }
    }
}

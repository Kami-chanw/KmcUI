import QtQuick
import QtQuick.Controls
import KmcUI

ToolTip {
    id: control
    property int radius: 0
    required property int location
    property color shadowColor: palette.shadow
    property int shadowBlur: 0

    onLocationChanged: {
        switch (location) {
        case KmcUI.Left:
            rightMargin = 0
            return
        case KmcUI.Right:
            leftMargin = 0
            return
        case KmcUI.Top:
            bottomMargin = 0
            return
        case KmcUI.Bottom:
            topMargin = 0
            return
        }
        throw new Exception("Invalid location for KmcUI.BubbleToolTip")
    }

    enter: Transition {
        NumberAnimation {
            target: control
            property: "opacity"
            duration: 80
            from: 0
            to: 1
        }
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth
                            + leftPadding + rightPadding) + leftMargin + rightMargin
                   + border.width * 2 + (location === KmcUI.Left
                                         || location === KmcUI.Right ? arrow.width : 0)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight
                             + topPadding + bottomPadding) + topMargin + bottomMargin
                    + border.width * 2 + (location === KmcUI.Top
                                          || location === KmcUI.Bottom ? arrow.height : 0)

    component ArrowData: QtObject {
        property int height
        property int width
        property int position
    }
    readonly property ArrowData arrow: ArrowData {
        height: 5
        width: 5
        position: {
            switch (location) {
            case KmcUI.Left:
            case KmcUI.Right:
                return control.height / 2
            case KmcUI.Top:
            case KmcUI.Bottom:
                return control.width / 2
            }
        }

        Component.onCompleted: {
            positionChanged()
        }

        onPositionChanged: {
            const borderOffset = control.border.width / 2

            switch (location) {
            case KmcUI.Left:
            case KmcUI.Right:
                const leftTopY = control.topMargin + borderOffset + control.radius
                const leftBottomY = control.height - control.bottomMargin - borderOffset
                var lowerBound = leftTopY + height / 2
                var upperBound = leftBottomY - control.radius - height / 2
                if (lowerBound > upperBound)
                    return
                if (position < lowerBound)
                    position = lowerBound
                else if (position > upperBound)
                    position = upperBound
                else
                    return
                console.warn("The arrow.position of KmcUI.BubbleToolTip out of range [" + lowerBound
                             + "," + upperBound + "]")
                return
            case KmcUI.Top:
            case KmcUI.Bottom:
                const leftTopX = control.leftMargin + borderOffset
                const rightTopX = control.width - control.rightMargin - borderOffset - control.radius
                lowerBound = leftTopX + control.radius + width / 2
                upperBound = rightTopX - width / 2
                if (lowerBound > upperBound)
                    return
                if (position < lowerBound)
                    position = lowerBound
                else if (position > upperBound)
                    position = upperBound
                else
                    return
                console.warn("The arrow.position of KmcUI.BubbleToolTip out of range [" + lowerBound
                             + "," + upperBound + "]")
                return
            }
        }
    }

    // @disable-check M300
    property KmcRectangle.BorderGroup border: KmcRectangle.BorderGroup {}

    x: {
        switch (location) {
        case KmcUI.Left:
            return -implicitWidth - 1
        case KmcUI.Right:
            return parent ? (parent.width + 1) : 0
        case KmcUI.Top:
        case KmcUI.Bottom:
            return parent ? parent.width / 2 - arrow.position : 0
        }
    }

    y: {
        switch (location) {
        case KmcUI.Left:
        case KmcUI.Right:
            return parent ? parent.height / 2 - arrow.position : 0
        case KmcUI.Top:
            return -implicitHeight - 1
        case KmcUI.Bottom:
            return parent ? (parent.height + 1) : 0
        }
    }
    contentItem: Item {
        Text {
            x: control.leftMargin + control.border.width + (location === KmcUI.Right ? arrow.width : 0)
            y: control.topMargin + control.border.width + (location === KmcUI.Bottom ? arrow.height : 0)
            text: control.text
            font: control.font
            color: control.palette.toolTipText
            wrapMode: Text.Wrap
        }
    }

    background: Canvas {
        height: control.height
        width: control.width
        onPaint: {
            var ctx = getContext("2d")
            if (control.shadowBlur) {
                ctx.shadowColor = control.shadowColor
                ctx.shadowBlur = control.shadowBlur
            }

            // begining
            const borderOffset = control.border.width / 2
            const ah = control.arrow.height
            const aw = control.arrow.width
            const apos = control.arrow.position

            ctx.beginPath()

            // calculate coordinate of 4 start points
            let leftTopX = control.leftMargin + borderOffset
            let leftTopY = control.topMargin + borderOffset + control.radius
            let leftBottomX = control.leftMargin + borderOffset + control.radius
            let leftBottomY = height - control.bottomMargin - borderOffset

            let rightBottomX = width - control.rightMargin - borderOffset
            let rightBottomY = leftBottomY - control.radius
            let rightTopX = rightBottomX - control.radius
            let rightTopY = leftTopY - control.radius

            switch (control.location) {
            case KmcUI.Left:
                rightBottomX -= aw
                rightTopX -= aw
                break
            case KmcUI.Right:
                leftTopX += aw
                leftBottomX += aw
                break
            case KmcUI.Top:
                leftBottomY -= ah
                rightBottomY -= ah
                break
            case KmcUI.Bottom:
                leftTopY += ah
                rightTopY += ah
            }

            // left part
            if (control.location === KmcUI.Right) {
                ctx.moveTo(leftTopX, leftTopY)
                // draw arrow
                ctx.lineTo(leftTopX, apos - ah / 2)
                ctx.lineTo(leftTopX - aw, apos)
                ctx.lineTo(leftTopX, apos + ah / 2)
                ctx.lineTo(leftTopX, leftBottomY - control.radius)
                ctx.arcTo(leftTopX, leftBottomY, leftBottomX, leftBottomY, control.radius)
            } else {
                ctx.moveTo(leftTopX, leftTopY)
            }

            ctx.lineTo(leftTopX, leftBottomY - control.radius)
            ctx.arcTo(leftTopX, leftBottomY, leftBottomX, leftBottomY, control.radius)

            // bottom part
            if (control.location === KmcUI.Top) {
                ctx.lineTo(apos - aw / 2, leftBottomY)
                ctx.lineTo(apos, leftBottomY + ah)
                ctx.lineTo(apos + aw / 2, leftBottomY)
            }
            ctx.lineTo(rightBottomX - control.radius, leftBottomY)
            ctx.arcTo(rightBottomX, leftBottomY, rightBottomX, rightBottomY, control.radius)

            // right part
            if (control.location === KmcUI.Left) {
                ctx.lineTo(rightBottomX, apos + ah / 2)
                ctx.lineTo(rightBottomX + aw, apos)
                ctx.lineTo(rightBottomX, apos - ah / 2)
            }
            ctx.lineTo(rightBottomX, rightTopY + control.radius)
            ctx.arcTo(rightBottomX, rightTopY, rightTopX, rightTopY, control.radius)

            // top part
            if (control.location === KmcUI.Bottom) {
                ctx.lineTo(apos + aw / 2, leftTopY)
                ctx.lineTo(apos, leftTopY - ah)
                ctx.lineTo(apos - aw / 2, leftTopY)
            }
            ctx.lineTo(leftTopX + control.radius, rightTopY)
            ctx.arcTo(leftTopX, rightTopY, leftTopX, leftTopY, control.radius)
            // ending
            ctx.closePath()
            ctx.lineWidth = control.border.width
            ctx.strokeStyle = "#000"
            ctx.stroke()
            ctx.shadowColor = "transparent"
            ctx.fillStyle = control.palette.toolTipBase
            ctx.fill()
            ctx.strokeStyle = control.border.color
            ctx.stroke()
        }
    }
}

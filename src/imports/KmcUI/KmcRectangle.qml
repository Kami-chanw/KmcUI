import QtQuick
import QtQuick.Controls
import KmcUI.Effects

Canvas {
    id: root
    property int radius: 0
    property int leftTopRadius: radius
    property int rightTopRadius: radius
    property int rightBottomRadius: radius
    property int leftBottomRadius: radius
    property color color: "white"
    default property alias data: container.data
    property alias contentItem: container

    onChildrenChanged: {
        for (const v of children) {
            if (v !== canvas && v !== container && v !== clipMask) {
                v.parent = container
            }
        }
    }

    component BorderGroup: QtObject {
        id: borderGroup
        property int width: 0
        property color color: "transparent"
        onColorChanged: {
            // @disable-check M325
            if (width == 0 && borderGroup.color !== "transparent")
                width = 1
        }
    }

    property BorderGroup border: BorderGroup {
        id: border
    }
    property BorderGroup leftBorder: BorderGroup {
        color: border.color
        width: border.width
    }
    property BorderGroup topBorder: BorderGroup {
        color: border.color
        width: border.width
    }
    property BorderGroup rightBorder: BorderGroup {
        color: border.color
        width: border.width
    }
    property BorderGroup bottomBorder: BorderGroup {
        color: border.color
        width: border.width
    }

    onPaint: {
        var ctx = getContext("2d")
        var x = root.leftBorder.width
        var y = root.topBorder.width
        var w = root.width - root.rightBorder.width - root.leftBorder.width
        var h = root.height - root.topBorder.width - root.bottomBorder.width
        ctx.save()
        ctx.beginPath()
        // top line
        ctx.lineWidth = root.topBorder.width * 2
        ctx.strokeStyle = root.topBorder.color
        ctx.moveTo(x + root.leftTopRadius, y)
        ctx.lineTo(x + w - root.rightTopRadius, y)
        ctx.arcTo(x + w, y, x + w, y + root.rightTopRadius, root.rightTopRadius)
        ctx.stroke()
        // right line
        ctx.lineWidth = root.rightBorder.width * 2
        ctx.strokeStyle = root.rightBorder.color
        ctx.lineTo(x + w, y + h - root.rightBottomRadius)
        ctx.arcTo(x + w, y + h, x + w - root.rightBottomRadius, y + h, root.rightBottomRadius)
        ctx.stroke()
        // bottom baseline
        ctx.lineWidth = root.bottomBorder.width * 2
        ctx.strokeStyle = root.bottomBorder.color
        ctx.lineTo(x + root.leftBottomRadius, y + h)
        ctx.arcTo(x, y + h, x, y + h - root.leftBottomRadius, root.leftBottomRadius)
        ctx.stroke()
        // left line
        ctx.lineWidth = root.leftBorder.width * 2
        ctx.strokeStyle = root.leftBorder.color
        ctx.lineTo(x, y + root.leftTopRadius)
        ctx.arcTo(x, y, x + root.leftTopRadius, y, root.leftTopRadius)
        ctx.stroke()

        ctx.closePath()
        ctx.fillStyle = root.color
        ctx.fill()
        ctx.restore()
    }

    Item {
        id: container
        anchors.fill: parent
        opacity: 0 // must be `opacity: 0` instead of `visible: false`, the later will disable all events.
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: false
        onPaint: {
            var ctx = getContext("2d")
            var x = root.leftBorder.width
            var y = root.topBorder.width
            var w = root.width - root.rightBorder.width - root.leftBorder.width
            var h = root.height - root.topBorder.width - root.bottomBorder.width

            ctx.save()
            ctx.beginPath()
            ctx.moveTo(x + root.leftTopRadius, y)
            ctx.lineTo(x + w - root.rightTopRadius, y)
            ctx.arcTo(x + w, y, x + w, y + root.rightTopRadius, root.rightTopRadius)
            ctx.lineTo(x + w, y + h - root.rightBottomRadius)
            ctx.arcTo(x + w, y + h, x + w - root.rightBottomRadius, y + h, root.rightBottomRadius)
            ctx.lineTo(x + root.leftBottomRadius, y + h)
            ctx.arcTo(x, y + h, x, y + h - root.leftBottomRadius, root.leftBottomRadius)
            ctx.lineTo(x, y + root.leftTopRadius)
            ctx.arcTo(x, y, x + root.leftTopRadius, y, root.leftTopRadius)
            ctx.closePath()
            ctx.fillStyle = "#000000"
            ctx.fill()
            ctx.restore()
        }
    }

    ClipMask {
        id: clipMask
        anchors.fill: container
        source: container
        maskSource: canvas
    }
}

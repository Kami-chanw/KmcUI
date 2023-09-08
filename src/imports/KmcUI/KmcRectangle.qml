import QtQuick
import QtQuick.Controls
import KmcUI.Effects
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property int radius: 0
    property int leftTopRadius: radius
    property int rightTopRadius: radius
    property int rightBottomRadius: radius
    property int leftBottomRadius: radius
    property alias color: container.color

    default property alias data: container.data

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onRadiusChanged: canvas.requestPaint()
    onLeftTopRadiusChanged: canvas.requestPaint()
    onRightTopRadiusChanged: canvas.requestPaint()
    onLeftBottomRadiusChanged: canvas.requestPaint()
    onRightBottomRadiusChanged: canvas.requestPaint()

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

    Rectangle {
        id: container
        width: root.width - leftBorder.width - rightBorder.width
        height: root.height - topBorder.width - bottomBorder.width
        visible: false
    }
    Rectangle {
        anchors.top: parent.top
        height: root.topBorder.width
        width: parent.width
        color: root.topBorder.color
        z: 1
    }

    Rectangle {
        anchors.left: parent.left
        height: parent.height
        width: root.leftBorder.width
        color: root.leftBorder.color
        z: 1
    }

    Rectangle {
        anchors.bottom: parent.bottom
        height: root.bottomBorder.width
        width: parent.width
        color: root.bottomBorder.color
        z: 1
    }

    Rectangle {
        anchors.right: parent.right
        height: parent.height
        width: root.rightBorder.width
        color: root.rightBorder.color
        z: 1
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: false
        onPaint: {
            var ctx = getContext("2d")
            var x = 0
            var y = 0
            var w = root.width
            var h = root.height
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
        anchors.fill: container
        source: container
        maskSource: canvas
    }
}

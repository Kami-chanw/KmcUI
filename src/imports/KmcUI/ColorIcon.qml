import QtQuick
import QtQuick.Effects

Item {
    id: control
    property alias color: effect.colorizationColor
    property alias source: icon.source

    Image {
        id: icon
        anchors.fill: parent
    }

    MultiEffect {
        id: effect
        anchors.fill: icon
        source: icon
        colorization: 1.0
    }
}

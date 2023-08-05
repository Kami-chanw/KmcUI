import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: control
    property alias color: effect.color
    property alias source: icon.source

    Image {
        id: icon
        anchors.fill: parent
    }
    ColorOverlay {
        id: effect
        anchors.fill: icon
        source: icon
    }
}

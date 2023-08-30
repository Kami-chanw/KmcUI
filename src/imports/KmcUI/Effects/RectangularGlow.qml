import QtQuick

Item {
    id: root
    property real glowRadius: 0.0
    property real spread: 0.0
    property color color: "white"
    property real cornerRadius: glowRadius

    ShaderEffect {
        x: (parent.width - width) / 2.0
        y: (parent.height - height) / 2.0
        width: parent.width + root.glowRadius * 2 + cornerRadius * 2
        height: parent.height + root.glowRadius * 2 + cornerRadius * 2

        function clampedCornerRadius() {
            var maxCornerRadius = Math.min(root.width, root.height) / 2 + glowRadius
            return Math.max(0, Math.min(root.cornerRadius, maxCornerRadius))
        }

        property color color: root.color
        property real inverseSpread: 1.0 - root.spread
        property real relativeSizeX: ((inverseSpread * inverseSpread) * root.glowRadius + cornerRadius * 2.0) / width
        property real relativeSizeY: relativeSizeX * (width / height)
        property real spread: root.spread / 2.0
        property real cornerRadius: clampedCornerRadius()

        fragmentShader: "qrc:/src/imports/KmcUI/Effects/shaders/rectangularglow.frag.qsb"
    }
}

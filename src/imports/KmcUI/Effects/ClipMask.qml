import QtQuick

Item {
    id: root
    required property Item source
    required property Item maskSource
    property bool invert: false
    ShaderEffect {
        anchors.fill: parent
        property bool invert: root.invert
        property var source: ShaderEffectSource {
            sourceItem: root.source
        }
        property var maskSource: ShaderEffectSource {
            sourceItem: root.maskSource
        }
        fragmentShader: "qrc:/assets/shaders/clipmask.frag.qsb"
    }
}

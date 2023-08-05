import QtQuick
import QtQuick.Shapes

Row {
    id: control
    spacing: 4

    required property string sequence
    property font font: Qt.font({
                                    "pointSize": 9
                                })
    palette {
        mid: "#2C2C2C"
        dark: "#1F1F1F"
        light: "#3D3D3D"
    }

    TextMetrics {
        id: oneLetterMetrics
        text: "W" // 'W' is the widest letter in alphabet, so we set min width of keyBackground to its width.
        font: control.font
    }

    Component {
        id: keyComponent
        Rectangle {
            property alias text: keyText.text
            width: keyBackground.width - 1
            height: keyBackground.height
            radius: keyBackground.radius
            border.color: control.palette.light
            color: control.palette.dark

            Rectangle {
                id: keyBackground
                radius: 3
                width: Math.max(keyText.contentWidth, oneLetterMetrics.width) + 12
                height: keyText.contentHeight + 3
                antialiasing: true
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -2
                color: control.palette.mid
            }
            Text {
                id: keyText
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -1
                color: control.palette.text
                font: control.font
            }
        }
    }

    Component {
        id: opComponent
        Text {
            id: opText
            color: control.palette.text
            font: control.font
        }
    }

    ListModel {
        id: listModel
    }

    Repeater {
        id: texts
        model: listModel
        delegate: Loader {
            sourceComponent: model.text !== "+" ? keyComponent : opComponent
            onLoaded: {
                item.text = model.text
            }
        }
    }

    TextMetrics {
        id: testLetterMetrics
        text: "W"
        font: control.font
    }
    Component.onCompleted: {
        const keys = sequence.split("+")
        const operators = []
        for (let ch of sequence) {
            if (ch === '+')
                operators.push(ch)
        }
        for (var i = 0; i < operators.length; ++i) {
            listModel.append({
                                 "text": keys[i]
                             })
            listModel.append({
                                 "text": operators[i]
                             })
        }
        listModel.append({
                             "text": keys[i]
                         })
    }
}

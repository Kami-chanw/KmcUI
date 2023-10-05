import QtQuick
import QtQuick.Controls

ItemDelegate {
    id: control

    property alias enabled: tapHandler.enabled // override ItemDelegate.enabled
    TapHandler {
        id: tapHandler
        onTapped: {
            expanded = !expanded
            forceHighlight()
        }
    }

    property bool expanded: false
    // the following properties will be initialized by ToolBox
    property int index
    property var model
    property var content
}

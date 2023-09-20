import QtQuick
import QtQuick.Controls

ItemDelegate {
    id: control

    TapHandler {
        onTapped: {
            toggleContent()
        }
    }

    // the following properties will be initialized by KmcTreeView
    property int index
    property var model
    property bool expanded
}

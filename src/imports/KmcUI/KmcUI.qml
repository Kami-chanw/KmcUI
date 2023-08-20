import QtQuick

QtObject {
    enum DragType {
        NoDrag = 0,
        DragTitle,
        DragWindow
    }

    enum Location {
        Left,
        Right,
        Top,
        Bottom
    }
}

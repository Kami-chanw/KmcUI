# ShadowWindow QML Component

The `ShadowWindow` component is a customizable window with a shadow effect and a flexible title bar. It provides functionality for window management, including buttons for minimize, maximize/restore, and close operations. The component supports dragging and resizing of the window, and it can be used to create stylish and interactive user interfaces.

### Properties

- `appIcon` (*Image*): The application icon image source.
- `title` (*TitleBar*): The text displayed in the title bar.
- `contentItem` (alias): The child items of the window's content area. If there is only one item, it will be set to fill content area.
- `background` (*Rect*): The background rectangle item of the window, which contains the title bar and `content`.
- `titleButton` (*enum*): Specifies the visibility and functionality of title bar buttons. It can be a combination of the following values: `KmcUI.TitleButton.Close`, `KmcUI.TitleButton.Minimize`, and `KmcUI.TitleButton.Maximize`. You can require all buttons by setting `KmcUI.TitleButton.Full`. The default value is `KmcUI.TitleButton.Close`. 
- `resizable` (*boolean*): Indicates whether the window is resizable. Default value is `false`.
- `dragType` (*enum*): Specifies the drag behavior of the window. It can be one of the following values: `KmcUI.DragType.NoDrag`, `KmcUI.DragType.DragTitle` which means the window will move only when drag title bar, or `KmcUI.DragType.DragWindow` which means the window will move when drag any place of the window. The default value is `KmcUI.DragType.DragWindow`.

## Example

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15

ShadowWindow {
    Component.onCompleted: {
        content.padding = 10
        // ...
    }

    contentItem: Rectangle {
        // Window content
    }
}
```

This is a simplified example, and you can customize the window further by modifying the properties and adding additional components and behavior as needed.

## Notes

- The `ShadowWindow` component provides built-in support for window management buttons, such as minimize, maximize/restore, and close. You can customize the visibility and behavior of these buttons by setting the `titleButton` property.
- The window can be dragged by clicking and dragging the title bar or the window itself, depending on the `dragType` property.
- The window can be resized if the `resizable` property is set to `true`.

## Content Area

Content refers to the area below the title bar, and `contentItem` is in it.

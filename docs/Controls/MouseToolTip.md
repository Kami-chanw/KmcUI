# MouseToolTip

The `MouseToolTip` is a custom QML component designed to display a tooltip near the mouse cursor. It provides a simple and customizable way to show informative text to the user.

## Properties

- **delay** (*int*): Specifies the delay in milliseconds before the tooltip is shown after the mouse enters the area.
- **timeout** (*int*): Specifies the timeout in milliseconds before the tooltip automatically closes.
- **text** (*string*): The text to be displayed in the tooltip.
- **font** (*Font*): The font used for the tooltip text.
- **cursorSize**(*int*): The size of the mouse cursor icon.
- **padding**(*int*): The amount of padding around the tooltip content.
- **horizontalPadding**(*int*): The horizontal padding around the tooltip content.
- **verticalPadding**(*int*): The vertical padding around the tooltip content.
- **mouseArea**(*MouseArea*): A mouse area to be binded.

## Example

```qml
MouseToolTip {
    delay: 500
    timeout: 3000
    text: "This is a tooltip example"
    font.pixelSize: 12
    cursorSize: 16
    padding: 5
    mouseArea: ma
    // Additional properties and customization can be added here
}
MouseArea {
    id: ma
    hoverEnabled: true
    // ...
}
```

In this example, a `MouseToolTip` component is created with a delay of 500 milliseconds before showing the tooltip and a timeout of 3000 milliseconds before automatically closing it. The tooltip displays the text "This is a tooltip example" with a font size of 12 pixels. The mouse cursor will have a size of 16 pixels, and the tooltip content will have a padding of 5 pixels.

Additional properties and customization specific to your use case can be added as needed.
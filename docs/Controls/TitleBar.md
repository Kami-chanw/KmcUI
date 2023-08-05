# Title Bar

The title bar is a component that includes an app icon (`Image`), a title text (`Text`), and a set of tool buttons (`Repeater`). It allows you to customize the appearance and behavior of the title bar by adding new buttons or modifying the existing ones.

## Properties

- `window` (`Window`): This property holds the titlebar's window.
Unless explicitly set, the window is automatically resolved by iterating the QML parent objects until a Window or an Item that has a window is found.
If `window` is still null, then the default behavior of minimizing, maximizing and closing button will be disabled.

- `titleText` (`Text`): The `Text` component representing the title text displayed in the title bar.

- `buttons` (`Repeater`): The `Repeater` component that manages the collection of tool buttons in the title bar. You can customize the buttons by modifying the model of this `Repeater`. Each button is represented by a delegate `Rectangle` in the `Repeater`, which contains various properties and methods for customization.

- `appIcon` (`Image`): The application icon image source.

- `titleButton` (`enum`): Specifies the visibility and functionality of title bar buttons. It can be a combination of the following values: `KmcUI.TitleButton.Close`, `KmcUI.TitleButton.Minimize`, and `KmcUI.TitleButton.Maximize`. You can require all buttons by setting `KmcUI.TitleButton.Full`. The default value is `KmcUI.TitleButton.Close`. 

## Methods

- `addButtonAt(index, name, icon, tooltip, onClicked)`: Adds a new tool button at the specified `index` position in the `buttons` model and returns new-added button. Note that `index` here represents the index of **visible** items. The callback function `onClicked` is used when current button is clicked. If you want to change `icon`, `tooltip` etc, you should travel `buttons.model`.

- `appendButton(name, icon, tooltip, onClicked))`: Appends a new tool button to the end of the `buttons` model and returns new-added button. Note that `index` here represents the index of **visible** items. The callback function `onClicked` is used when current button is clicked.

- `buttonAt(index)`: Retrieves the tool button at the specified `index` position in the `buttons` model. Returns the corresponding button delegate `Rectangle` object.

- `buttonByName(name)`: Retrieves the tool button with the specified `name` from the `buttons` model. Returns the corresponding button delegate `Rectangle` object.

- `moveButton(from, to)`: Moves the tool button at position `from` in the `buttons` model to position `to`. This method allows you to change the order of the buttons in the title bar.

## Properties of `buttons`


- `buttonWidth` (`int`): The width of the buttons. By default, it is equal to the height of the buttons.

- `buttonHeight` (`int`): The height of the buttons.

- `icons.width` (`int`): The width of the icons displayed on the buttons.

- `icons.height` (`int`): The height of the icons displayed on the buttons.

- `icons.color` (`color`): The color of the icons displayed on the buttons. Note that you should change `TitleBar.palette.button` to alter the background color of buttons.

- `hover` (`ButtonAnimData`): An object that defines the animation data for the button when it is in the hover state. The `ButtonAnimData` type is used to define animation data for the buttons in the title bar. It contains properties that control the duration and colors used for button animations in different states.
`inDuration`/`outDuration` is a `int` that represents the duration of the animation when transitioning from normal to hover/hover to normal state. `iconColor` and `buttonColor` are the color of the button's icon/background when hover.

- `press` (`ButtonAnimData`): An object that defines the animation data for the button when it is in the pressed state. `inDuration`/`outDuration` is a `int` that represents the duration of the animation when transitioning from hover to press/press to hover state. `iconColor` and `buttonColor` are the color of the button's icon/background when pressed.

### Example of customizing a TitleBar
```qml
TitleBar {
    id: title
    color: "transparent"
    anchors{
        top: parent.top
        left: parent.left
        right: parent.right
    } 
    height: 30
    window: control

    buttons {
        hover.buttonColor: "#25ffffff"
        press.buttonColor: "#43ffffff"
    }

    Component.onCompleted: {
        let closeButton = title.buttonByName("Close")
        closeButton.hover.buttonColor = "#E81123"
        closeButton.hover.iconColor = "white"

        closeButton.press.buttonColor = "#AAE81123"
        closeButton.press.iconColor = "white"
    }
}
```
## Properties of `button`

- `icon` (`Image`): The `Image` component representing the icon displayed on the button.

- `name` (`string`): The name assigned to the button.

- `hover` (`ButtonAnimData`): Customize hover animation behavior of a specific button. By default,  See `buttons.hover` for details.

- `press` (`ButtonAnimData`): Customize press animation behavior of a specific button. See `buttons.press` for details.

- `enabled` (bool): This property holds whether the button receives mouse and keyboard events. By default this is true. If `enabled` is false, `TitleBar.palette.disabled.button` will be appied to icon color.

## Example of adding a new button

```qml
// Assume titleButton is KmcUI.TitleButton.Close | KmcUI.TitleButton.Minimize, and now we add a new button between Close button and Minimize button.
let button = title.addButtonAt(1, "Button",  "qrc:/icons/buton.svg", "This is a button", () => console.log("clicked me"))
```
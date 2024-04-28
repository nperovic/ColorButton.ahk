# ColorButton.ahk
An extended method for changing a button's background color.

## Features
- Easily change a button's background color.
- Compatible with [AutoHotkey v2.1-alpha.9](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha) or later.
- Learn more about the ahk v2.1-alpha: [Click here](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)

## Demo
**On Windows 11**  
![colorButton_win11_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/567a8145-c7c3-4800-9210-613b3bdc2f71)

**On Windows 10**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)



## Usage
1. Download the [ColorButton.ahk](ColorButton.ahk) file.
2. Include the [ColorButton.ahk](ColorButton.ahk) file in your script.
3. Implement dark theme by using the `SetBackColor` method.

## Example
```py
#requires AutoHotkey v2.1-alpha.9
#include <ColorButton>

myGui := Gui()
myGui.SetFont("cWhite s24", "Segoe UI")
myGui.BackColor := 0x2c2c2c
btn := myGui.AddButton(, "SUPREME")
btn.SetBackColor(0xaa2031)
myGui.Show("w300 h300")
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.


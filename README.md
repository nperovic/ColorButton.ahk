# ColorButton.ahk
An extended method for changing a button's background color.

[English](#colorbuttonahk) | [中文](#colorbuttonahk-1) | [Srpski](#colorbuttonahk-2)


## Features
- Easily change a button's background color.
- Automatically set the text colour to white or black depends on the background colour.
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
3. Implement the background color by using the `SetBackColor` method.

## Example

```js
/**
 * @param {Gui.Button} myBtn omitted.
 * @param {integer} btnBgColor Button's background color.
 * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`.
 * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
 * > For Windows 11: Enabled. (value: 9)  
 * > For Windows 10: Disabled.   
 */
myBtn.SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?)
```

### Basic Button
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

### Rounded Button
```py
btn.SetBackColor(0xaa2031,, 9)
myGui.Show("w300 h300")
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

# ColorButton.ahk
本程式庫為內建類別 `Gui.Button` 擴充了一個更改按鈕背景顏色的方法。

## 特點
- 輕鬆更改按鈕的背景顏色。
- 自動根據背景色彩的深淺設定文字色彩 (深色背景+白色文字或淺色背景+黑色文字)。
- 支援 AutoHotkey v2.1-alpha.9 或更高版本。
- 想知道更多關於 [ahk v2.1-alpha](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha) 的資訊，請按[這裡](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)。

**在 Windows 11 上**  
![colorButton_win11_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/567a8145-c7c3-4800-9210-613b3bdc2f71)

**在 Windows 10 上**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)

## 用法
1. 下載 [ColorButton.ahk](ColorButton.ahk) 文件。
2. 在您的程式碼中加入 [ColorButton.ahk](ColorButton.ahk) 。
3. 使用 `SetBackColor` 方法變更按鈕背景色彩。

## 範例

```js
/**
 * @param {Gui.Button} myBtn omitted.
 * @param {integer} btnBgColor Button's background color.
 * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`.
 * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
 * > For Windows 11: Enabled. (value: 9)  
 * > For Windows 10: Disabled.   
 */
myBtn.SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?)
```

### 基本按鈕
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

### 圓角按鈕
```py
btn.SetBackColor(0xaa2031,, 9)
myGui.Show("w300 h300")
```


## 許可證
本項目根據 MIT 許可證進行許可 - 請參閱 [LICENSE.md](LICENSE.md) 文件以獲取詳細資訊。

---

# ColorButton.ahk
Proširena metoda za promenu boje pozadine dugmeta.

## Karakteristike
- Lako promenite boju pozadine dugmeta.
- Kompatibilno sa AutoHotkey [v2.1-alpha.9](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha) ili novijim verzijama.
- Saznajte više o ahk v2.1-alpha: [Kliknite ovde](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)

## Demo
**Na Windows 11**  
![colorButton_win11_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/567a8145-c7c3-4800-9210-613b3bdc2f71)

**Na Windows 10**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)


## Upotreba
1. Preuzmite ColorButton.ahk datoteku.
2. Uključite ColorButton.ahk datoteku u vaš skript.
3. Implementirajte boju pozadine koristeći `SetBackColor` metodu.

## Primer
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

## Licenca
Ovaj projekat je licenciran pod MIT Licencom - za detalje pogledajte [LICENSE.md](LICENSE.md) datoteku.

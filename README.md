# ColorButton.ahk
An extended method for changing a button's background color.

[English](#colorbuttonahk) | [中文](#colorbuttonahk-1) | [Srpski](#colorbuttonahk-2)

![20240530-1454-20 5059500](https://github.com/nperovic/ColorButton.ahk/assets/122501303/c951d745-160a-4fe1-912d-42d27d97481a)


## Features
- Easily change a button's background color.
- Automatically set the text colour to white or black depends on the background colour.
- Compatible with [AutoHotkey v2.1-alpha.9](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha) or later. **(Update: v2.0 is now supported too.)**
- Learn more about the ahk v2.1-alpha: [Click here](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)

## Basic Look
**On Windows 11**  
![colorButton_win11_demo_new](https://github.com/nperovic/ColorButton.ahk/assets/122501303/b4d4f274-5605-48d7-95e4-efcde768f4af)

**On Windows 10**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)


## Usage
1. Download the [ColorButton.ahk](ColorButton.ahk) file.
2. Include the [ColorButton.ahk](ColorButton.ahk) file in your script.
3. Implement the background color by using the `SetBackColor` method.

## Example
### Parameters 
```scala
/**
 * @param {integer} btnBgColor Button's background color. (RGB)
 * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`. **(Usually let it be transparent looks better.)**
 * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
 * > For Windows 11: Enabled. (value: 9)  
 * > For Windows 10: Disabled.
 * @param {Integer} [showFocusedBorder=true] Highlight the border of the button when it's focused. 
 */
SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)
```
## `BtnObj.SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)`
```php
#Requires AutoHotkey v2
#Include <ColorButton>

myGui := Gui()
myGui.SetFont("cWhite s20", "Segoe UI")
myGui.BackColor := 0x2c2c2c

/** @type {_BtnColor} */
btn := myGui.AddButton("w300", "Rounded Button")
btn.SetBackColor(0xaa2031,, 9)

/** @type {_BtnColor} */
btn2 := myGui.AddButton("wp", "No Focused Outline")
btn2.SetBackColor(0xffd155,, 9, false)

/** @type {_BtnColor} */
btn3 := myGui.AddButton("wp", "Rectangle Button")
btn3.SetBackColor("0x7755ff",, 0)

/** @type {_BtnColor} */
btn4 := myGui.AddButton("wp", "No Focused Outline")
btn4.SetBackColor("0x55ffd4", , 0, 0)

myGui.Show("w280 AutoSize")
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

# ColorButton.ahk
本程式庫為內建類別 `Gui.Button` 擴充了一個更改按鈕背景顏色的方法。

## 特點
- 輕鬆更改按鈕的背景顏色。
- 自動根據背景色彩的深淺設定文字色彩 (深色背景+白色文字或淺色背景+黑色文字)。
- 支援 AutoHotkey v2.0 或更高版本。
- 想知道更多關於 [ahk v2.1-alpha](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha) 的資訊，請按[這裡](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)。

**在 Windows 11 上**  
![colorButton_win11_demo_new](https://github.com/nperovic/ColorButton.ahk/assets/122501303/b4d4f274-5605-48d7-95e4-efcde768f4af)

**在 Windows 10 上**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)

## 用法
1. 下載 [ColorButton.ahk](ColorButton.ahk) 文件。
2. 在您的程式碼中加入 [ColorButton.ahk](ColorButton.ahk) 。
3. 使用 `SetBackColor` 方法變更按鈕背景色彩。

## 範例
### 參數 
```scala
/**
 * @param {integer} btnBgColor 按鈕的背景顏色。(RGB)
 * @param {integer} [colorBehindBtn] 按鈕周圍區域的顏色。如果省略，將與 `myGui.BackColor` 相同。**(通常設為透明看起來會更好。)**
 * @param {integer} [roundedCorner] 指定按鈕的圓角偏好。如果省略，: 
 * > Windows 11: 啟用。(值：9)  
 * > Windows 10: 禁用。
 * @param {Integer} [showFocusedBorder=true] 當按鈕獲得焦點時突出顯示邊框。
 */
SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)
```
## `BtnObj.SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)`
```php
#Requires AutoHotkey v2
#Include <ColorButton>

myGui := Gui()
myGui.SetFont("cWhite s20", "Microsoft Yahei UI")
myGui.BackColor := 0x2c2c2c

/** @type {_BtnColor} */
btn := myGui.AddButton("w300", "圓角按鈕")
btn.SetBackColor(0xaa2031,, 9)

/** @type {_BtnColor} */
btn2 := myGui.AddButton("wp", "聚焦時不顯示邊框")
btn2.SetBackColor(0xffd155,, 9, false)

/** @type {_BtnColor} */
btn3 := myGui.AddButton("wp", "正方形按鈕")
btn3.SetBackColor("0x7755ff",, 0)

/** @type {_BtnColor} */
btn4 := myGui.AddButton("wp", "聚焦時不顯示邊框")
btn4.SetBackColor("0x55ffd4", , 0, 0)

myGui.Show("w280 AutoSize")
```


## 許可證
本項目根據 MIT 許可證進行許可 - 請參閱 [LICENSE.md](LICENSE.md) 文件以獲取詳細資訊。

---

# ColorButton.ahk
Proširena metoda za promenu boje pozadine dugmeta.

## Karakteristike
- Lako promenite boju pozadine dugmeta.
- Kompatibilno sa AutoHotkey v2.0 ili novijim verzijama.
- Saznajte više o ahk v2.1-alpha: [Kliknite ovde](https://github.com/AutoHotkey/AutoHotkeyDocs/tree/alpha)

## Demo
**Na Windows 11**  
![colorButton_win11_demo_new](https://github.com/nperovic/ColorButton.ahk/assets/122501303/b4d4f274-5605-48d7-95e4-efcde768f4af)

**Na Windows 10**  
![colorButton_win10_demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/63c20602-b45d-4030-93a9-0a258c70acb4)


## Upotreba
1. Preuzmite [ColorButton.ahk](ColorButton.ahk) datoteku.
2. Uključite [ColorButton.ahk](ColorButton.ahk) datoteku u vaš skript.
3. Implementirajte boju pozadine koristeći `SetBackColor` metodu.

## Primer
### Parameters 
```scala
/**
 * @param {integer} btnBgColor Button's background color. (RGB)
 * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`. **(Usually let it be transparent looks better.)**
 * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
 * > For Windows 11: Enabled. (value: 9)  
 * > For Windows 10: Disabled.
 * @param {Integer} [showFocusedBorder=true] Highlight the border of the button when it's focused. 
 */
SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)
```
## `BtnObj.SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)`
```php
#Requires AutoHotkey v2
#Include <ColorButton>

myGui := Gui()
myGui.SetFont("cWhite s20", "Segoe UI")
myGui.BackColor := 0x2c2c2c

/** @type {_BtnColor} */
btn := myGui.AddButton("w300", "Rounded Button")
btn.SetBackColor(0xaa2031,, 9)

/** @type {_BtnColor} */
btn2 := myGui.AddButton("wp", "No Focused Outline")
btn2.SetBackColor(0xffd155,, 9, false)

/** @type {_BtnColor} */
btn3 := myGui.AddButton("wp", "Rectangle Button")
btn3.SetBackColor("0x7755ff",, 0)

/** @type {_BtnColor} */
btn4 := myGui.AddButton("wp", "No Focused Outline")
btn4.SetBackColor("0x55ffd4", , 0, 0)

myGui.Show("w280 AutoSize")
```

## Licenca
Ovaj projekat je licenciran pod MIT Licencom - za detalje pogledajte [LICENSE.md](LICENSE.md) datoteku.

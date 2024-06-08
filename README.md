# ColorButton.ahk
An extended method for changing a button's background, text and border color.

[English](#colorbuttonahk) | [中文](#colorbuttonahk-1) | [Srpski](#colorbuttonahk-2)

![ColorButton Demo](https://github.com/nperovic/ColorButton.ahk/assets/122501303/9e5c91f9-7982-4b8f-8330-fafa989a0fb8)


## Features
- Easily change a button's background, text and border color.
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
 * Configures a button's appearance.
 * @param {number} bgColor - Button's background color (RGB).
 * @param {number} [txColor] - Button text color (RGB). If omitted, the text colour will be automatically set to white or black depends on the background colour.
 * @param {boolean} [showBorder=1]
 * - `n` : The higher the value, the thicker the button's border when focused.
 * - `1` : Highlight when focused.
 * - `0` : No border displayed.
 * - `-1`: Border always visible.
 * - `-n`: The lower the value, the thicker the button's border when always visible.
 * @param {number} [borderColor=0xFFFFFF] - Button border color (RGB).
 * @param {number} [roundedCorner] - Rounded corner preference for the button. If omitted,     
 * - For Windows 11: Enabled (value: 9).
 * - For Windows 10: Disabled.
 */
SetColor(bgColor, txColor?, showBorder := 1, borderColor := 0xFFFFFF, roundedCorner?)
```
## `BtnObj.SetColor(bgColor, txColor?, showBorder := 1, borderColor := 0xFFFFFF, roundedCorner?)`
```php
#Requires AutoHotkey v2
#Include <ColorButton>

/** @type {_BtnColor} */
btn := btn2 := btn3 := btn4 := unset

/* Rounded (Windows 11) or rectangle (Windows 10) button that will get its border on show when it's focused. */
btn := myGui.AddButton("xm w300", "Rounded Button")
btn.SetColor("0xaa2031", "FFFFCC",, "fff5cc", 9)

/* When you press the button each time, the background and text colours of the button swap around. */
btnClicked(btn, *) {
    static toggle    := 0
    static textColor := btn.TextColor
    static backColor := btn.BackColor
    
    if (toggle^=1) {
        btn.TextColor := btn.BorderColor := backColor
        btn.backColor := textColor
    } else {
        btn.TextColor := btn.BorderColor := TextColor
        btn.backColor := backColor
    }
}

/* Rounded (Windows 11) or rectangle (Windows 10) button that’s got its border on show all the time. */
btn2 := myGui.AddButton("yp wp", "Border Always Visible")
btn2.SetColor(myGui.BackColor, "fff5cc")
btn2.BorderColor := btn2.TextColor
btn2.ShowBorder  := -5

/* Rectangle Button and show border outline when the button's focused. */
btn3 := myGui.AddButton("xm wp", "Rectangle Button")
btn3.SetColor("4e479a", "c6c1f7", 2)
btn3.RoundedCorner := 0

/* Rectangle Button with no border outline. */
btn4 := myGui.AddButton("yp wp", "No Focused Outline")
btn4.SetBackColor("008080",, 0, 0,, "AFEEEE")

myGui.Show("w280 AutoSize")
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

# ColorButton.ahk
本程式庫為內建類別 `Gui.Button` 擴充了一個更改按鈕背景背景、文字和邊框顏色的方法。

## 特點
- 輕鬆更改按鈕的背景、文字和邊框顏色。
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
 * 設定按鈕的外觀。
 * @param {number} bgColor - 按鈕的背景顏色（RGB）。
 * @param {number} [txColor] - 按鈕文字顏色（RGB）。如果未指定，文字顏色將根據背景顏色自動設置為白色或黑色。
 * @param {boolean} [showBorder=1]
 * - `1` : 聚焦時高亮顯示。
 * - `0` : 無邊框顯示。
 * - `-1`: 邊框始終可見。
 * @param {number} [borderColor=0xFFFFFF] - 按鈕邊框顏色（RGB）。
 * @param {number} [roundedCorner] - 按鈕的圓角偏好。如果未指定：
 * - 對於 Windows 11：啟用（值：9）。
 * - 對於 Windows 10：禁用。
 */
SetColor(bgColor, txColor?, showBorder := 1, borderColor := 0xFFFFFF, roundedCorner?)
```
## `BtnObj.SetColor(bgColor, txColor?, showBorder := 1, borderColor := 0xFFFFFF, roundedCorner?)`
```php
#Requires AutoHotkey v2
#Include <ColorButton>

/** @type {_BtnColor} */
btn := btn2 := btn3 := btn4 := unset

btn := myGui.AddButton("xm w300", "Rounded Button")
btn.SetColor("0xaa2031", "FFFFCC",, "fff5cc", 9)
btn.OnEvent("Click", btnClicked)

btnClicked(btn, *) {
    static toggle    := 0
    static textColor := btn.TextColor
    static backColor := btn.BackColor
    
    if (toggle^=1) {
        btn.TextColor := backColor
        btn.backColor := textColor
    } else {
        btn.TextColor := TextColor
        btn.backColor := backColor
    }
}

btn2 := myGui.AddButton("yp wp", "Border Always Visible")
btn2.SetColor(myGui.BackColor, "fff5cc")
btn2.BorderColor := btn2.TextColor
btn2.ShowBorder  := -1

btn3 := myGui.AddButton("xm wp", "Rectangle Button")
btn3.SetColor("4e479a", "c6c1f7")
btn3.RoundedCorner := 0

btn4 := myGui.AddButton("yp wp", "No Focused Outline")
btn4.SetBackColor("008080",, 0, 0,, "AFEEEE")

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

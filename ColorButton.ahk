/************************************************************************
 * @description An extended method for changing a button's background color.
 * @file ColorButton.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic/ColorButton.ahk
 * @date 2024/04/28
 * @version 1.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.1-alpha.9
#SingleInstance

class RECT {
    left: i32, top: i32, right: i32, bottom: i32
}

class NMCUSTOMDRAWINFO {
    hdr        : NMCUSTOMDRAWINFO.NMHDR
    dwDrawStage: u32
    hdc        : uptr
    rc         : RECT
    dwItemSpec : uptr
    uItemState : i32
    lItemlParam: iptr

    class NMHDR {
        hwndFrom: uptr
        idFrom  : uptr
        code    : i32
    }
}

/**
 * The extended class for the built-in `Gui.Button` class.
 * @method SetBackColor Set the button's background color
 * @example
 * btn := myGui.AddButton(, "SUPREME")
 * btn.SetBackColor(0xaa2031)
 */
class _BtnColor extends Gui.Button {
    static __New() => super.Prototype.SetBackColor := ObjBindMethod(this, "SetBackColor")

    /**
     * @param {Gui.Button} myBtn 
     * @param {integer} bkColor 
     */
    static SetBackColor(myBtn, bkColor)
    {
        static IS_WIN11         := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static WM_CTLCOLORBTN   := 0x0135
        static NM_CUSTOMDRAW    := -12
        static WM_DESTROY       := 0x0002
        static WS_EX_COMPOSITED := 0x02000000
        static WS_CLIPCHILDREN  := 0x02000000
        static WS_CLIPSIBLINGS  := 0x04000000
        
        clr        := (IsNumber(bkColor) ? bkColor : Number((!InStr(bkColor, "0x") ? "0x" : "") bkColor))
        hoverColor := BrightenColor(clr, 10)
        hbrush     := CreateSolidBrush(ColorHex(myBtn.Gui.BackColor))
        
        myBtn.Gui.Opt("+E" WS_EX_COMPOSITED " +" WS_CLIPCHILDREN)
        myBtn.Gui.OnEvent("Close", (*) => (DeleteObject(hbrush), unset))

        myBtn.Opt("+" WS_CLIPSIBLINGS)
        SetWindowTheme(myBtn.hwnd, IsColorDark(clr) ? "DarkMode_Explorer" : "Explorer")
        myBtn.Redraw()

        myBtn.Gui.OnMessage(WM_CTLCOLORBTN, (GuiObj, wParam, *) {
            Critical(-1)
            SelectObject(wParam, hbrush)
            SetBkMode(wParam, 0)
            SetBkColor(wParam, ColorHex(GuiObj.BackColor))
            return hbrush
        })

        myBtn.OnNotify(NM_CUSTOMDRAW, (gCtrl, lParam) {
            static CDDS_PREPAINT := 1
            static CDIS_HOT      := 0x0040
            static DC_BRUSH      := 18
            static DC_PEN        := 19
            
            Critical(-1)

            /** @type {NMCUSTOMDRAWINFO} */ 
            lpnmCD := StructFromPtr(NMCUSTOMDRAWINFO, lParam)
            
            if (lpnmCD.hdr.code != NM_CUSTOMDRAW || lpnmCD.hdr.hwndFrom != gCtrl.hwnd || lpnmCD.dwDrawStage != CDDS_PREPAINT)
                return

            brushColor := RgbToBgr(GetKeyState("LButton", "P") || !(lpnmCD.uItemState & CDIS_HOT) ? clr : hoverColor )

            SetBkMode(lpnmCD.hdc, 0)
            SetDCBrushColor(lpnmCD.hdc, brushColor)
            SelectObject(lpnmCD.hdc, bru := GetStockObject(DC_BRUSH))
            SetDCPenColor(lpnmCD.hdc, brushColor)
            SelectObject(lpnmCD.hdc, GetStockObject(DC_PEN))
            
            if IS_WIN11
                RoundRect(lpnmCD.hdc, lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right, lpnmCD.rc.bottom, 8, 8)
            else
                FillRect(lpnmCD.hdc, lpnmCD.rc, bru)

            return true
        })

        RgbToBgr(color) => (IsInteger(color) ? ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16) : NUMBER(RegExReplace(STRING(color), "Si)c?(?:0x)?(?<R>\w{2})(?<G>\w{2})(?<B>\w{2})", "0x${B}${G}${R}")))

        CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        ColorHex(clr) => Number((!InStr(clr, "0x") ? "0x" : "") clr)

        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

        SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

        DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')

        FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

        IsColorDark(clr) => 
            ( (clr >> 16 & 0xFF) / 255 * 0.2126 
            + (clr >>  8 & 0xFF) / 255 * 0.7152 
            + (clr       & 0xFF) / 255 * 0.0722 < 0.5 )

        RGB(R := 255, G := 255, B := 255) => ((R << 16) | (G << 8) | B)
        
        BrightenColor(clr, perc := 5) => ((p := perc / 100 + 1), RGB(Round(Min(255, (clr >> 16 & 0xFF) * p)), Round(Min(255, (clr >> 8 & 0xFF) * p)), Round(Min(255, (clr & 0xFF) * p))))

        RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight) => DllCall('Gdi32\RoundRect', 'ptr', hdc, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidth, 'int', nHeight, 'int')
        
        SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)
        
        SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
        
        SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')
                
        SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')
        
        SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')
    }
}

/* 
; Example

myGui := Gui()
myGui.SetFont("cWhite s24", "Segoe UI")
myGui.BackColor := 0x2c2c2c
btn := myGui.AddButton(, "SUPREME")
btn.SetBackColor(0xaa2031)
myGui.Show("w300 h300")

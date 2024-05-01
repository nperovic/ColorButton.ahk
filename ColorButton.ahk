/************************************************************************
 * @description An extended method for changing a button's background color.
 * @file ColorButton.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic/ColorButton.ahk
 * @date 2024/04/29
 * @version 1.1.0
 ***********************************************************************/

#Requires AutoHotkey v2
#SingleInstance

; ================================================================================

; #region For v2.1-alpha.9 or later.

; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.

class NMCUSTOMDRAWINFO {
    hdr        : NMCUSTOMDRAWINFO.NMHDR
    dwDrawStage: u32
    hdc        : uptr
    rc         : NMCUSTOMDRAWINFO.RECT
    dwItemSpec : uptr
    uItemState : i32
    lItemlParam: iptr

    class RECT {
        left: i32, top: i32, right: i32, bottom: i32
    }

    class NMHDR {
        hwndFrom: uptr
        idFrom  : uptr
        code    : i32
    }
}

; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.

; #endregion

; ================================================================================

; #region For v2.0 user

; If you're using v2.1-alpha.9 or later, delete the section BELOW.
; If you're using v2.1-alpha.9 or later, delete the section BELOW.
; If you're using v2.1-alpha.9 or later, delete the section BELOW.

StructFromPtr(StructClass, Address) => StructClass(Address)

class NMCUSTOMDRAWINFO
{
    static Call(ptr)
    {
        return {
            hdr: {
                hwndFrom: NumGet(ptr, 0 ,"uptr"),
                idFrom  : NumGet(ptr, 8 ,"uptr"),
                code    : NumGet(ptr, 16 ,"int")
            },
            dwDrawStage: NumGet(ptr, 24, "uint"),
            hdc        : NumGet(ptr, 32, "uptr"),
            rc         : RECT(
                NumGet(ptr, 40, "uint"),
                NumGet(ptr, 44, "uint"),
                NumGet(ptr, 48, "int"),
                NumGet(ptr, 52, "int")
            ),
            dwItemSpec : NumGet(ptr, 56, "uptr"),
            uItemState : NumGet(ptr, 64, "int"),
            lItemlParam: NumGet(ptr, 72, "iptr")
        }
        
        RECT(left := 0, top := 0, right := 0, bottom := 0)
        {
            static ofst := Map("left", 0, "top", 4, "right", 8, "bottom", 12)
            NumPut("int", left, "int", top, "int", right, "int", bottom, buf := Buffer(16))
            for k, v in ofst
                buf.DefineProp(k, {Get: NumGet.Bind(, v, "int"), Set: IntPut.Bind(v)})
            return buf
            IntPut(ofst, _, v) => NumPut("int", v, _, ofst)
        }
    }
}

class _Gui extends Gui
{
    static __New() => (super.Prototype.OnMessage := ObjBindMethod(this, "OnMessage"))

    static OnMessage(obj, Msg, Callback, AddRemove?)
    {
        OnMessage(Msg, _callback, AddRemove?)
        obj.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd)
        {
            if (uMsg = Msg && hWnd = obj.hwnd)
                return Callback(obj, wParam, lParam, uMsg)
        }
    }
}

; If you're using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're using v2.1-alpha.9 or later, delete the section ABOVE.

; #endregion

; ================================================================================

/**
 * The extended class for the built-in `Gui.Button` class.
 * @method SetBackColor Set the button's background color
 * @example
 * btn := myGui.AddButton(, "SUPREME")
 * btn.SetBackColor(0xaa2031)
 */
class _BtnColor extends Gui.Button
{
    static __New() => super.Prototype.SetBackColor := ObjBindMethod(this, "SetBackColor")

    /**
     * @param {Gui.Button} myBtn omitted.
     * @param {integer} btnBgColor Button's background color. (RGB)
     * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`. **(Usually let it be transparent looks better.)**
     * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted,        : 
     * > For Windows 11: Enabled. (value: 9)  
     * > For Windows 10: Disabled.   
     */
    static SetBackColor(myBtn, btnBgColor, colorBehindBtn?, roundedCorner?)
    {
        static BS_FLAT          := 0x8000
        static BS_BITMAP        := 0x0080
        static IS_WIN11         := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static WM_CTLCOLORBTN   := 0x0135
        static NM_CUSTOMDRAW    := -12
        static WM_DESTROY       := 0x0002
        static WS_EX_COMPOSITED := 0x02000000
        static WS_CLIPSIBLINGS  := 0x04000000

        rcRgn       := unset
        clr         := IsNumber(btnBgColor) ? btnBgColor : ColorHex(btnBgColor)
        isDark      := IsColorDark(clr)
        hoverColor  := RgbToBgr(BrightenColor(clr, isDark ? 15 : -15))
        pushedColor := RgbToBgr(BrightenColor(clr, isDark ? -10 : 10))
        clr         := RgbToBgr(clr)
        btnBkColr   := (colorBehindBtn??0) && RgbToBgr(ColorHex(myBtn.Gui.BackColor))
        hbrush      := btnBkColr ? CreateSolidBrush(btnBkColr) : GetStockObject(5)

        myBtn.Gui.Opt("+" WS_CLIPSIBLINGS)
        myBtn.Gui.OnMessage(WM_CTLCOLORBTN, ON_WM_CTLCOLORBTN)

        if btnBkColr
            myBtn.Gui.OnEvent("Close", (*) => DeleteObject(hbrush))

        myBtn.Opt("+" (WS_CLIPSIBLINGS | BS_FLAT | BS_BITMAP))
        SetWindowTheme(myBtn.hwnd, isDark ? "DarkMode_Explorer" : "Explorer")
        myBtn.OnNotify(NM_CUSTOMDRAW, ON_NM_CUSTOMDRAW)
        myBtn.Redraw()

        ON_WM_CTLCOLORBTN(GuiObj, wParam, lParam, Msg)
        {
            Critical(-1)

            if btnBkColr 
                SelectObject(wParam, hbrush),
                SetBkMode(wParam, 0),
                SetBkColor(wParam, btnBkColr)

            return hbrush 
        }

        ON_NM_CUSTOMDRAW(gCtrl, lParam)
        {
            static CDDS_PREPAINT        := 0x1
            static CDDS_PREERASE        := 0x3
            static CDIS_HOT             := 0x40
            static CDRF_NOTIFYPOSTPAINT := 0x10
            static CDRF_SKIPPOSTPAINT   := 0x100
            static CDRF_SKIPDEFAULT     := 0x4
            static CDRF_NOTIFYPOSTERASE := 0x40
            static CDRF_DODEFAULT       := 0x0
            static DC_BRUSH             := GetStockObject(18)
            static DC_PEN               := GetStockObject(19)
            
            Critical(-1)

            lpnmCD := StructFromPtr(NMCUSTOMDRAWINFO, lParam)

            if (lpnmCD.hdr.code != NM_CUSTOMDRAW || lpnmCD.hdr.hwndFrom != gCtrl.hwnd)
                return
            
            switch lpnmCD.dwDrawStage {
            case CDDS_PREERASE:
            {
                if (roundedCorner ?? IS_WIN11) {
                    rcRgn := CreateRoundRectRgn(lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right, lpnmCD.rc.bottom, roundedCorner ?? 9, roundedCorner ?? 9)
                    SetWindowRgn(gCtrl.hwnd, rcRgn, 1)
                }

                SetBkMode(lpnmCD.hdc, 0)
                return CDRF_NOTIFYPOSTERASE 
            }
            case CDDS_PREPAINT: 
            {
                brushColor := (!(lpnmCD.uItemState & CDIS_HOT) ? clr : (GetKeyState("LButton", "P")) ? pushedColor : hoverColor)

                SelectObject(lpnmCD.hdc, DC_BRUSH)
                SetDCBrushColor(lpnmCD.hdc, brushColor)
                
                SelectObject(lpnmCD.hdc, DC_PEN)
                SetDCPenColor(lpnmCD.hdc, gCtrl.Focused ? 0xFFFFFF : brushColor)

                if gCtrl.Focused 
                    DrawFocusRect(lpnmCD.hdc, lpnmCD.rc)

                rounded := !!(rcRgn ?? 0)

                RoundRect(lpnmCD.hdc, lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right - rounded, lpnmCD.rc.bottom - rounded, roundedCorner ?? 9, roundedCorner ?? 9)

                if rounded {
                    DeleteObject(rcRgn)
                    rcRgn := ""
                }

                return CDRF_NOTIFYPOSTPAINT 
            }}
            
            return CDRF_DODEFAULT
        }

        static RgbToBgr(color) => (IsInteger(color) ? ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16) : NUMBER(RegExReplace(STRING(color), "Si)c?(?:0x)?(?<R>\w{2})(?<G>\w{2})(?<B>\w{2})", "0x${B}${G}${R}")))

        static CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('Gdi32\CreateRoundRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')

        static CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        static ColorHex(clr) => Number((!InStr(clr, "0x") ? "0x" : "") clr)

        static DrawFocusRect(hDC, lprc) => DllCall("User32\DrawFocusRect", "ptr", hDC, "ptr", lprc, "int")

        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

        static SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')

        static SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

        static SetWindowRgn(hWnd, hRgn, bRedraw) => DllCall("User32\SetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int", bRedraw, "int")

        static DeleteObject(hObject) {
            DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')
        }

        static FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

        static IsColorDark(clr) => 
            ( (clr >> 16 & 0xFF) / 255 * 0.2126 
            + (clr >>  8 & 0xFF) / 255 * 0.7152 
            + (clr       & 0xFF) / 255 * 0.0722 < 0.5 )

        static RGB(R := 255, G := 255, B := 255) => ((R << 16) | (G << 8) | B)
        
        static BrightenColor(clr, perc := 5) => ((p := perc / 100 + 1), RGB(Round(Min(255, (clr >> 16 & 0xFF) * p)), Round(Min(255, (clr >> 8 & 0xFF) * p)), Round(Min(255, (clr & 0xFF) * p))))

        static RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight) => DllCall('Gdi32\RoundRect', 'ptr', hdc, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidth, 'int', nHeight, 'int')
        
        static SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)
        
        static SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
        
        static SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')
                
        static SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')
        
        static SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')
    }
}

; Example
/*
myGui := Gui()
myGui.SetFont("cWhite s24", "Segoe UI")
myGui.BackColor := 0x2c2c2c
btn := myGui.AddButton(, "SUPREME")
btn.SetBackColor(0xaa2031)
btn2 := myGui.AddButton(, "SUPREME")
btn2.SetBackColor(0xffd155)
myGui.Show("w300 h300")

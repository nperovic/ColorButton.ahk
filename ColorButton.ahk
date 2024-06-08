  /************************************************************************
 * @description Customize a button's background, text, and border color.
 * @file ColorButton.ahk
 * @author Nikola Perovic
 * @link (https://github.com/nperovic/ColorButton.ahk)
 * @date 2024/06/08
 * @version 1.3.1
 ***********************************************************************/

#Requires AutoHotkey v2.0.16
#SingleInstance

; ================================================================================ 

; #region For v2.1-alpha.9 or later.

; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.

; class NMCUSTOMDRAWINFO
; {
;     hdr        : NMCUSTOMDRAWINFO.NMHDR
;     dwDrawStage: u32
;     hdc        : uptr
;     rc         : NMCUSTOMDRAWINFO.RECT
;     dwItemSpec : uptr
;     uItemState : i32
;     lItemlParam: iptr

;     class RECT
;     {
;         left: i32, top: i32, right: i32, bottom: i32
;         width  => this.right - this.left
;         height => this.bottom - this.top
;     }

;     class NMHDR
;     {
;         hwndFrom: uptr
;         idFrom  : uptr
;         code    : i32
;     }

;     __New(ptr?) {
;         if (ptr??0) {
;             scc := StructFromPtr(NMCUSTOMDRAWINFO, ptr?)
;             for p, v in scc.Props() {
;                 if IsObject(v) {
;                     for p2, v2 in v.Props()
;                         try this.%p%.%p2% := v2
;                 } else
;                     try this.%p% := v
;             }
;         }
;     }

;     ptr  => ObjGetDataPtr(this)
;     size => ObjGetDataSize(this)
; }

; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.
; If you're NOT using v2.1-alpha.9 or later, delete the section ABOVE.

; #endregion

; ================================================================================ 

; #region For v2.0 user

; If you're using v2.1-alpha.9 or later, delete the section BELOW and uncomment the section ABOVE.
; If you're using v2.1-alpha.9 or later, delete the section BELOW and uncomment the section ABOVE.
; If you're using v2.1-alpha.9 or later, delete the section BELOW and uncomment the section ABOVE.

; StructFromPtr(StructClass, Address) => StructClass(Address)

Buffer.Prototype.PropDesc := PropDesc
PropDesc(buf, name, ofst, type, ptr?) {
    if (ptr??0)
        NumPut(type, NumGet(ptr, ofst, type), buf, ofst)
    buf.DefineProp(name, {
        Get: NumGet.Bind(, ofst, type),
        Set: (p, v) => NumPut(type, v, buf, ofst)
    })
}

class NMHDR extends Buffer {
    __New(ptr?) {
        super.__New(A_PtrSize * 2 + 4)
        this.PropDesc("hwndFrom", 0, "uptr", ptr?)
        this.PropDesc("idFrom", A_PtrSize,"uptr", ptr?)   
        this.PropDesc("code", A_PtrSize * 2 ,"int", ptr?)     
    }
}

class RECT extends Buffer { 
    __New(ptr?) {
        super.__New(16, 0)
        for i, prop in ["left", "top", "right", "bottom"]
            this.PropDesc(prop, 4 * (i-1), "int", ptr?)
        this.DefineProp("Width", {Get: rc => (rc.right - rc.left)})
        this.DefineProp("Height", {Get: rc => (rc.bottom - rc.top)})
    }
}

class NMCUSTOMDRAWINFO extends Buffer
{
    __New(ptr?) {
        static x64 := (A_PtrSize = 8)
        super.__New(x64 ? 80 : 48)
        this.hdr := NMHDR(ptr?)
        this.rc  := RECT((ptr??0) ? ptr + (x64 ? 40 : 20) : unset)
        this.PropDesc("dwDrawStage", x64 ? 24 : 12, "uint", ptr?)  
        this.PropDesc("hdc"        , x64 ? 32 : 16, "uptr", ptr?)          
        this.PropDesc("dwItemSpec" , x64 ? 56 : 36, "uptr", ptr?)   
        this.PropDesc("uItemState" , x64 ? 64 : 40, "int", ptr?)   
        this.PropDesc("lItemlParam", x64 ? 72 : 44, "iptr", ptr?)
    }
}

class _Gui extends Gui
{
    static __New(p := this.Prototype, sp := Gui.Prototype) {
        if !sp.HasOwnProp("OnMessage")
            sp.DefineProp("OnMessage", p.GetOwnPropDesc("OnMessage"))
        else
            p.DeleteProp("OnMessage")
    }

    OnMessage(Msg, Callback, MaxThreads?)
    {
        OnMessage(Msg, _callback, MaxThreads?)
        super.OnEvent("Close", g => OnMessage(Msg, _callback, 0))

        _callback(wParam, lParam, uMsg, hWnd) {
            try if (uMsg = Msg && hwnd = this.hwnd)
                return Callback(this, wParam, lParam, uMsg)
        }
    }

    class _Control extends Gui.Control
    {
        static __New() => _Gui.__New(this.Prototype, super.Prototype)

        OnMessage(Msg, Callback, AddRemove := 1)
        {
            static SubClasses := Map()
            static HookedMsgs := Map()
    
            if !SubClasses.Has(this.hwnd) {
                SubClasses[this.hwnd] := CallbackCreate(SubClassProc,, 6)
                HookedMsgs[this.hwnd] := Map(Msg, Callback.Bind(this))
                SetWindowSubclass(this, SubClasses[this.hwnd])
                this.Gui.OnEvent("Close", RemoveWindowSubclass)
            }
            
            hm := HookedMsgs[this.hwnd]
    
            if AddRemove
                hm[Msg] := Callback.Bind(this)
            else if hm.Has(Msg)
                hm.Delete(Msg)
    
            SubClassProc(hWnd?, uMsg?, wParam?, lParam?, uIdSubclass?, dwRefData?)
            {
                if HookedMsgs.Has(uIdSubclass) && HookedMsgs[uIdSubclass].Has(uMsg) {
                    reply := HookedMsgs[uIdSubclass][uMsg](wParam?, lParam?, uMsg?)
                    if IsSet(reply)
                        return reply
                }
    
                return DefSubclassProc(hwnd, uMsg?, wParam?, lParam?)
            }
    
            DefSubclassProc(hwnd?, uMsg?, wParam?, lParam?) => DllCall("DefSubclassProc", "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    
            SetWindowSubclass(obj, cb) => DllCall("SetWindowSubclass", "Ptr", obj.hwnd, "Ptr", cb, "Ptr", obj.hwnd, "Ptr", 0)
    
            RemoveWindowSubclass(*)
            {
                for hwnd, cb in SubClasses.Clone() {
                    try {
                        DllCall("RemoveWindowSubclass", "Ptr", hWnd, "Ptr", cb, "Ptr", hWnd)
                        CallbackFree(cb)
                        SubClasses.Delete(hwnd)
                    }
                }
            }
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
    static __New() {
        for prop in this.Prototype.OwnProps()
            if (!super.Prototype.HasProp(prop) && SubStr(prop, 1, 1) != "_")
                super.Prototype.DefineProp(prop, this.Prototype.GetOwnPropDesc(prop))

        Gui.CheckBox.Prototype.DefineProp("GetTextFlags", this.Prototype.GetOwnPropDesc("GetTextFlags"))
        Gui.Radio.Prototype.DefineProp("GetTextFlags", this.Prototype.GetOwnPropDesc("GetTextFlags"))
    }

    GetTextFlags(&center?, &vcenter?, &right?, &bottom?)
    {
        static BS_BOTTOM     := 0x800
        static BS_CENTER     := 0x300
        static BS_LEFT       := 0x100
        static BS_LEFTTEXT   := 0x20
        static BS_MULTILINE  := 0x2000
        static BS_RIGHT      := 0x200
        static BS_TOP        := 0x0400
        static BS_VCENTER    := 0x0C00
        static DT_BOTTOM     := 0x8
        static DT_CENTER     := 0x1
        static DT_LEFT       := 0x0
        static DT_RIGHT      := 0x2
        static DT_SINGLELINE := 0x20
        static DT_TOP        := 0x0
        static DT_VCENTER    := 0x4
        static DT_WORDBREAK  := 0x10
        
        dwStyle     := ControlGetStyle(this)
        txC         := dwStyle & BS_CENTER
        txR         := dwStyle & BS_RIGHT
        txL         := dwStyle & BS_LEFT
        dwTextFlags := (dwStyle & BS_BOTTOM) ? DT_BOTTOM : !(dwStyle & BS_TOP) ? DT_VCENTER : DT_TOP
        
        if (this.Type = "Button") 
            dwTextFlags |= (txC && txR && !txL) ? DT_RIGHT : (txC && txL && !txR) ? DT_LEFT : DT_CENTER
        else
            dwTextFlags |= txL && txR ? DT_CENTER : !txL && txR ? DT_RIGHT : DT_LEFT

        if !(dwStyle & BS_MULTILINE) ; || (dwStyle & BS_VCENTER)
            dwTextFlags |= DT_SINGLELINE
        
        center  := !!(dwTextFlags & DT_CENTER)
        vcenter := !!(dwTextFlags & DT_VCENTER)
        right   := !!(dwTextFlags & DT_RIGHT)
        bottom  := !!(dwTextFlags & DT_BOTTOM)
        
        return dwTextFlags | DT_WORDBREAK
    }

    /** @prop {Integer} TextColor Set/ Get the Button Text Color (RGB). (To set the text colour, you must have used `SetColor()`, `SetBackColor()`, or `BackColor` to set the background colour at least once beforehand.) */
    TextColor {
        Get => this.HasProp("_textColor") && _BtnColor.RgbToBgr(this._textColor)
        Set => this._textColor := _BtnColor.RgbToBgr(value)
    }

    /** @prop {Integer} BackColor Set/ Get the Button background Color (RGB). */
    BackColor {
        Get => this.HasProp("_clr") && _BtnColor.RgbToBgr(this._clr)
        Set {
            if !this.HasProp("_first")
                this.SetColor(value)
            else {
                b := _BtnColor
                this.opt("-Redraw")
                this._clr         := b.RgbToBgr(value)
                this._isDark      := b.IsColorDark(clr := b.RgbToBgr(this._clr))
                this._hoverColor  := b.RgbToBgr(b.BrightenColor(clr, this._isDark ? 20 : -20))
                this._pushedColor := b.RgbToBgr(b.BrightenColor(clr, this._isDark ? -10 : 10))
                this.opt("+Redraw")
            }
        }
    }

    /** @prop {Integer} BorderColor Button border color (RGB). (To set the border colour, you must have used `SetColor()`, `SetBackColor()`, or `BackColor` to set the background colour at least once beforehand.)*/
    BorderColor {
        Get => this.HasProp("_borderColor") && _BtnColor.RgbToBgr(this._borderColor)
        Set => this._borderColor := _BtnColor.RgbToBgr(value)
    }
    
    /** @prop {Integer} RoundedCorner Rounded corner preference for the button.  (To set the rounded corner preference, you must have used `SetColor()`, `SetBackColor()`, or `BackColor` to set the background colour at least once beforehand.) */
    RoundedCorner {
        Get => this.HasProp("_roundedCorner") && this._roundedCorner
        Set => this._roundedCorner := value
    }

    /**
     * @prop {Integer} ShowBorder
     * Border preference. (To set the border preference, you must have used `SetColor()`, `SetBackColor()`, or `BackColor` to set the background colour at least once beforehand.)
     * - `n` : The higher the value, the thicker the button's border when focused.
     * - `1` : Highlight when focused.
     * - `0` : No border displayed.
     * - `-1`: Border always visible.
     * - `-n`: The lower the value, the thicker the button's border when always visible.
     */
    ShowBorder {
        Get => this.HasProp("_showBorder") && this._showBorder
        Set {
            if IsNumber(Value)
                this._showBorder := value
            else throw TypeError("The value must be a number.", "ShowBorder")
        }
    }

    /**
     * Configures a button's appearance.
     * @param {number} bgColor - Button's background color (RGB).
     * @param {number} [colorBehindBtn] - Color of the button's surrounding area (defaults to `myGui.BackColor`).
     * @param {number} [roundedCorner] - Rounded corner preference for the button. If omitted, 
     * - For Windows 11: Enabled (value: 9).
     * - For Windows 10: Disabled.
     * @param {boolean} [showBorder=1]
     * - `n` : The higher the value, the thicker the button's border when focused.
     * - `1`: Highlight when focused.
     * - `0`: No border displayed.
     * - `-1`: Border always visible.
     * - `-n`: The lower the value, the thicker the button's border when always visible.
     * @param {number} [borderColor=0xFFFFFF] - Button border color (RGB).
     * @param {number} [txColor] - Button text color (RGB). If omitted, the text colour will be automatically set to white or black depends on the background colour.
     */
    SetBackColor(bgColor, colorBehindBtn?, roundedCorner?, showBorder := 1, borderColor := 0xFFFFFF, txColor?) => this.SetColor(bgColor, txColor?, showBorder, borderColor?, roundedCorner?)
    
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
    { 
        static BS_BITMAP       := 0x0080
        static BS_FLAT         := 0x8000
        static IS_WIN11        := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static IS_ALPHA        := (VerCompare(A_AhkVersion, "2.1-alpha.9") >= 0)
        static NM_CUSTOMDRAW   := -12
        static WM_CTLCOLORBTN  := 0x0135
        static WS_CLIPSIBLINGS := 0x04000000
        static BTN_STYLE       := (WS_CLIPSIBLINGS | BS_FLAT | BS_BITMAP) 

        this._first         := 1
        this._roundedCorner := roundedCorner ?? (IS_WIN11 ? 9 : 0)
        this._showBorder    := showBorder
        this._clr           := ColorHex(bgColor)
        this._isDark        := _BtnColor.IsColorDark(this._clr)
        this._hoverColor    := _BtnColor.RgbToBgr(BrightenColor(this._clr, this._isDark ? 20 : -20))
        this._pushedColor   := _BtnColor.RgbToBgr(BrightenColor(this._clr, this._isDark ? -10 : 10))
        this._clr           := _BtnColor.RgbToBgr(this._clr)
        this._btnBkColor    := (colorBehindBtn ?? !IS_WIN11) && _BtnColor.RgbToBgr("0x" (this.Gui.BackColor))
        this._borderColor   := _BtnColor.RgbToBgr(borderColor)
        
        if !this.HasProp("_textColor") || IsSet(txColor)
            this._textColor := _BtnColor.RgbToBgr(txColor ?? (this._isDark ? 0xFFFFFF : 0))
        
        ; Uncomment the line blow if the button corner is a bit off.
        ; this.Gui.OnMessage(WM_CTLCOLORBTN, ON_WM_CTLCOLORBTN)

        if this._btnBkColor
            this.Gui.OnEvent("Close", (*) => DeleteObject(this.__hbrush))

        this.Opt(BTN_STYLE (IsSet(colorBehindBtn) ? " Background" colorBehindBtn : "")) ;  
        this.OnNotify(NM_CUSTOMDRAW, ON_NM_CUSTOMDRAW)

        if this._isDark
            SetWindowTheme(this.hwnd, "DarkMode_Explorer")

        SetWindowPos(this.hwnd, 0,,,,, 0x4043)
        this.Redraw()

        ON_NM_CUSTOMDRAW(gCtrl, lParam)
        {
            static CDDS_PREPAINT    := 0x1
            static CDIS_HOT         := 0x40
            static CDRF_DODEFAULT   := 0x0
            static CDRF_SKIPDEFAULT := 0x4
            static DC_BRUSH         := GetStockObject(18)
            static DC_PEN           := GetStockObject(19)
            static DT_CALCRECT      := 0x400
            static DT_WORDBREAK     := 0x10
            static PS_SOLID         := 0
            
            nmcd := NMCUSTOMDRAWINFO(lParam)

            if (nmcd.hdr.code != NM_CUSTOMDRAW 
            || nmcd.hdr.hwndFrom != gCtrl.hwnd
            || nmcd.dwDrawStage  != CDDS_PREPAINT)
                return CDRF_DODEFAULT
            
            ; Determine the background colour based on the button's status.
            isPressed := GetKeyState("LButton", "P")
            isHot     := (nmcd.uItemState & CDIS_HOT)
            brushColor := penColor := (!isHot || this._first ? this._clr : isPressed ? this._pushedColor : this._hoverColor)
            
            ; Set Rounded Corner Preference ----------------------------------------------

            rc     := nmcd.rc
            corner := this._roundedCorner
            SetWindowRgn(gCtrl.hwnd, CreateRoundRectRgn(rc.left, rc.top, rc.right, rc.bottom, corner, corner), 1)
            GetWindowRgn(gCtrl.hwnd, rcRgn := CreateRectRgn())
            
            ; Draw Border ----------------------------------------------------------------

            if ((this._showBorder < 0) || (this._showBorder > 0 && gCtrl.Focused)) {
                penColor := this._showBorder > 0 && !gCtrl.Focused ? penColor : this._borderColor
                hpen     := CreatePen(PS_SOLID, this._showBorder, penColor)
                SelectObject(nmcd.hdc, hpen)
                FrameRect(nmcd.hdc, rc, DC_PEN)                
            } else {
                SelectObject(nmcd.hdc, DC_PEN)
                SetDCPenColor(nmcd.hdc, penColor)
            }

            ; Draw Background ------------------------------------------------------------

            SelectObject(nmcd.hdc, DC_BRUSH)
            SetDCBrushColor(nmcd.hdc, brushColor)
            RoundRect(nmcd.hdc, rc.left, rc.top, rc.right-1, rc.bottom-1, corner, corner)

            ; Darw Text ------------------------------------------------------------------

            textPtr     := StrPtr(gCtrl.Text)
            dwTextFlags := this.GetTextFlags(&hCenter, &vCenter, &right, &bottom)
            SetBkMode(nmcd.hdc, 0)
            SetTextColor(nmcd.hdc, this._textColor)

            CopyRect(rcT := !NMCUSTOMDRAWINFO.HasProp("RECT") && IsSet(RECT) ? RECT() : NMCUSTOMDRAWINFO.RECT(), nmcd.rc)
            
            ; Calculate the text rect.
            DrawText(nmcd.hdc, textPtr, -1, rcT, DT_CALCRECT | dwTextFlags)

            if (hCenter || right)
                offsetW := ((nmcd.rc.width - rcT.Width - (right * 4)) / (hCenter ? 2 : 1))

            if (bottom || vCenter)
                offsetH := ((nmcd.rc.height - rct.Height - (bottom * 4)) / (vCenter ? 2 : 1))
                
            OffsetRect(rcT, offsetW ?? 2,offsetH ?? 2)
            DrawText(nmcd.hdc, textPtr, -1, rcT, dwTextFlags)

            if this._first
                this._first := 0

            DeleteObject(rcRgn)
            
            if (pen??0)
                DeleteObject(hpen)

            SetWindowPos(this.hwnd, 0, 0, 0, 0, 0, 0x4043)

            return CDRF_SKIPDEFAULT 
        }

        ON_WM_CTLCOLORBTN(GuiObj, wParam, lParam, Msg)
        {
            if (lParam != this.hwnd || !this.Focused)
                return

            SelectObject(wParam, hbrush := GetStockObject(18))
            SetBkMode(wParam, 0)

            if (colorBehindBtn ?? !IS_WIN11) {
                SetDCBrushColor(wParam, this._btnBkColor)
                SetBkColor(wParam, this._btnBkColor)
            }

            return hbrush 
        }

        BrightenColor(clr, perc := 5) => _BtnColor.BrightenColor(clr, perc)

        ColorHex(clr) => Number(((Type(clr) = "string" && SubStr(clr, 1, 2) != "0x") ? "0x" clr : clr))

        CopyRect(lprcDst, lprcSrc) => DllCall("CopyRect", "ptr", lprcDst, "ptr", lprcSrc, "int")

        CreateRectRgn(nLeftRect := 0, nTopRect := 0, nRightRect := 0, nBottomRect := 0) => DllCall('Gdi32\CreateRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'ptr')

        CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('Gdi32\CreateRoundRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')

        CreatePen(fnPenStyle, nWidth, crColor) => DllCall('Gdi32\CreatePen', 'int', fnPenStyle, 'int', nWidth, 'uint', crColor, 'ptr')

        CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        DefWindowProc(hWnd, Msg, wParam, lParam) => DllCall("User32\DefWindowProc", "ptr", hWnd, "uint", Msg, "uptr", wParam, "uptr", lParam, "ptr")

        DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')

        DrawText(hDC, lpchText, nCount, lpRect, uFormat) => DllCall("DrawText", "ptr", hDC, "ptr", lpchText, "int", nCount, "ptr", lpRect, "uint", uFormat, "int")

        FrameRect(hDC, lprc, hbr) => DllCall("FrameRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

        FrameRgn(hdc, hrgn, hbr, nWidth, nHeight) => DllCall('Gdi32\FrameRgn', 'ptr', hdc, 'ptr', hrgn, 'ptr', hbr, 'int', nWidth, 'int', nHeight, 'int')

        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

        GetWindowRgn(hWnd, hRgn, *) => DllCall("User32\GetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int")

        OffsetRect(lprc, dx, dy) => DllCall("User32\OffsetRect", "ptr", lprc, "int", dx, "int", dy, "int")

        RGB(R := 255, G := 255, B := 255) => _BtnColor.RGB(R, G, B)

        RoundRect(hdc, nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight) => DllCall('Gdi32\RoundRect', 'ptr', hdc, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidth, 'int', nHeight, 'int')

        SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')

        SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')

        SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetTextColor(hdc, color) => DllCall("SetTextColor", "Ptr", hdc, "UInt", color)

        SetWindowPos(hWnd, hWndInsertAfter, X := 0, Y := 0, cx := 0, cy := 0, uFlags := 0x40) => DllCall("User32\SetWindowPos", "ptr", hWnd, "ptr", hWndInsertAfter, "int", X, "int", Y, "int", cx, "int", cy, "uint", uFlags, "int")

        SetWindowRgn(hWnd, hRgn, bRedraw) => DllCall("User32\SetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int", bRedraw, "int")

        SetWindowTheme(hwnd, appName, subIdList?) => DllCall("uxtheme\SetWindowTheme", "ptr", hwnd, "ptr", StrPtr(appName), "ptr", subIdList ?? 0)
    }

    static RGB(R := 255, G := 255, B := 255) => ((R << 16) | (G << 8) | B)

    static BrightenColor(clr, perc := 5) => ((p := perc / 100 + 1), _BtnColor.RGB(Round(Min(255, (clr >> 16 & 0xFF) * p)), Round(Min(255, (clr >> 8 & 0xFF) * p)), Round(Min(255, (clr & 0xFF) * p))))
    
    static IsColorDark(clr) => (((clr >> 16 & 0xFF) / 255 * 0.2126 + (clr >> 8 & 0xFF) / 255 * 0.7152 + (clr & 0xFF) / 255 * 0.0722) < 0.5)

    static RgbToBgr(color) => (Type(color) = "string") ? this.RgbToBgr(Number(SubStr(Color, 1, 2) = "0x" ? color : "0x" color)) : (Color >> 16 & 0xFF) | (Color & 0xFF00) | ((Color & 0xFF) << 16)
}


; Example - ColorButton
myGui := Gui("Resize")
myGui.SetFont("cWhite s20", "Segoe UI")

DllCall("Dwmapi\DwmSetWindowAttribute", "Ptr", myGui.hwnd, "UInt", 20, "Ptr*", 1, "UInt", 4)
myGui.BackColor := 0x202020

/** @type {_BtnColor} */
btn := btn2 := btn3 := btn4 := unset

; Rounded (Windows 11) or rectangle (Windows 10) button that will get its border on show when it's focused.
btn := myGui.AddButton("xm w300", "Rounded Button")
btn.SetColor("0xaa2031", "FFFFCC",, "fff5cc", 9)

; When you press the button each time, the background and text colours of the button swap around.
btn.OnEvent("Click", btnClicked)
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

; Rounded (Windows 11) or rectangle (Windows 10) button that’s got its border on show all the time.
btn2 := myGui.AddButton("yp wp", "Border Always Visible")
btn2.SetColor(myGui.BackColor, "fff5cc")
btn2.BorderColor := btn2.TextColor
btn2.ShowBorder  := -5

; Rectangle Button and show border outline when the button's focused.
btn3 := myGui.AddButton("xm wp", "Rectangle Button")
btn3.SetColor("4e479a", "c6c1f7", 2)
btn3.RoundedCorner := 0

; Rectangle Button with no border outline.
btn4 := myGui.AddButton("yp wp", "No Focused Outline")
btn4.SetBackColor("008080",, 0, 0,, "AFEEEE")

myGui.Show("w280 AutoSize")
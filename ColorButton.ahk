  /************************************************************************
 * @description An extended method for changing a button's background color. 
 * @file ColorButton.ahk
 * @author Nikola Perovic
 * @link (https://github.com/nperovic/ColorButton.ahk)
 * @date 2024/05/30
 * @version 1.2.1
 ***********************************************************************/

#Requires AutoHotkey v2.0.15
#SingleInstance

; ================================================================================ 

; #region For v2.1-alpha.9 or later.

; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.
; If you're NOT using v2.1-alpha.9 or later, delete the section BELOW.

; class NMCUSTOMDRAWINFO {
; hdr        : NMCUSTOMDRAWINFO.NMHDR
; dwDrawStage: u32
; hdc        : uptr
; rc         : NMCUSTOMDRAWINFO.RECT
; dwItemSpec : uptr
; uItemState : i32
; lItemlParam: iptr

;     class RECT {
; left: i32, top: i32, right: i32, bottom: i32
;     }

;     class NMHDR {
; hwndFrom: uptr
; idFrom  : uptr
; code    : i32
;     }
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
        super.__New(16)
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
    static __New() => super.Prototype.DefineProp("SetBackColor", this.Prototype.GetOwnPropDesc("SetBackColor"))
    
    /**
     * @param {integer} btnBgColor Button's background color. (RGB)
     * @param {integer} [colorBehindBtn] The color of the button's surrounding area. If omitted, if will be the same as `myGui.BackColor`. **(Usually let it be transparent looks better.)**
     * @param {integer} [roundedCorner] Specifies the rounded corner preference for the button. If omitted:   
     * - For Windows 11: Enabled. (value: 9)  
     * - For Windows 10: Disabled.
     * @param {Integer} [showFocusedBorder=true] Highlight the border of the button when it's focused. 
     */
    SetBackColor(btnBgColor, colorBehindBtn?, roundedCorner?, showFocusedBorder := true)
    {
        static BS_FLAT          := 0x8000
        static BS_BITMAP        := 0x0080
        static IS_WIN11         := (VerCompare(A_OSVersion, "10.0.22200") >= 0)
        static WM_CTLCOLORBTN   := 0x0135
        static NM_CUSTOMDRAW    := -12
        static WM_DESTROY       := 0x0002
        static WS_EX_COMPOSITED := 0x02000000
        static WS_CLIPSIBLINGS  := 0x04000000
        static BTN_STYLE        := (WS_CLIPSIBLINGS | BS_FLAT | BS_BITMAP)

        clr         := IsNumber(btnBgColor) ? btnBgColor : ColorHex(btnBgColor)
        isDark      := IsColorDark(clr)
        hoverColor  := RgbToBgr(BrightenColor(clr, isDark ? 15 : -15))
        pushedColor := RgbToBgr(BrightenColor(clr, isDark ? -10 : 10))
        clr         := RgbToBgr(clr)
        btnBkColr   := (colorBehindBtn ?? !IS_WIN11) && RgbToBgr(ColorHex(this.Gui.BackColor))
        hbrush      := (colorBehindBtn ?? !IS_WIN11) ? CreateSolidBrush(btnBkColr) : GetStockObject(5)

        this.Gui.OnMessage(WM_CTLCOLORBTN, ON_WM_CTLCOLORBTN)

        if btnBkColr
            this.Gui.OnEvent("Close", (*) => DeleteObject(hbrush))

        this.Opt(BTN_STYLE (IsSet(colorBehindBtn) ? " Background" colorBehindBtn : "")) ;  
        this.OnNotify(NM_CUSTOMDRAW, (gCtrl, lParam) => ON_NM_CUSTOMDRAW(gCtrl, lParam))
        SetWindowTheme(this.hwnd, isDark ? "DarkMode_Explorer" : "Explorer")
        this.Redraw()
        SetWindowPos(this.hwnd, 0,,,,, 0x43)

        ON_WM_CTLCOLORBTN(GuiObj, wParam, lParam, Msg)
        {
            if (lParam != this.hwnd || !this.Focused)
                return

            SelectObject(wParam, hbrush)
            SetBkMode(wParam, 0)

            if (colorBehindBtn ?? !IS_WIN11) 
                SetBkColor(wParam, btnBkColr)

            return hbrush 
        }

        first := 1

        ON_NM_CUSTOMDRAW(gCtrl, lParam)
        {
            static CDDS_POSTPAINT       := 0x000002
            static CDDS_PREERASE        := 0x3
            static CDDS_PREPAINT        := 0x1
            static CDIS_HOT             := 0x40
            static CDRF_DODEFAULT       := 0x0
            static CDRF_DOERASE         := 0x0008
            static CDRF_NOTIFYPOSTERASE := 0x40
            static CDRF_NOTIFYPOSTPAINT := 0x10
            static CDRF_SKIPDEFAULT     := 0x0004
            static CDRF_SKIPDEFAULT     := 0x4
            static CDRF_SKIPPOSTPAINT   := 0x100
            static DC_BRUSH             := GetStockObject(18)
            static DC_PEN               := GetStockObject(19)

            if IsSet(StructFromPtr)
                try lpnmCD := StructFromPtr(NMCUSTOMDRAWINFO, lParam)
            
            lpnmCD := lpnmCD ?? NMCUSTOMDRAWINFO(lParam)

            if (lpnmCD.hdr.code != NM_CUSTOMDRAW ||lpnmCD.hdr.hwndFrom != gCtrl.hwnd)
                return CDRF_DODEFAULT
            
            switch lpnmCD.dwDrawStage {
            case CDDS_POSTPAINT: return CDRF_SKIPDEFAULT
            case CDDS_PREPAINT : 
            {
                isPressed   := GetKeyState("LButton", "P")
                corner      := (roundedCorner ?? (IS_WIN11 ? 9 : 0))
                drawFocused := (showFocusedBorder && !first && gCtrl.Focused && !isPressed)
                brushColor  := (!(lpnmCD.uItemState & CDIS_HOT) || first ? clr : isPressed ? pushedColor : hoverColor)
                penColor    := (drawFocused ? 0xFFFFFF : brushColor)

                InflateRect(rc := lpnmCD.rc, -4, -4)
                SetWindowRgn(gCtrl.hwnd, rcRgn := CreateRoundRectRgn(rc.left, rc.top, rc.right, rc.bottom, corner, corner), 1)

                SelectObject(lpnmCD.hdc, DC_BRUSH)
                SetDCBrushColor(lpnmCD.hdc, brushColor)
                SelectObject(lpnmCD.hdc, DC_PEN)
                SetDCPenColor(lpnmCD.hdc, penColor)
                SetBkMode(lpnmCD.hdc, 0)

                if drawFocused {
                    InflateRect(lpnmCD.rc, -1, -1)
                    DrawFocusRect(lpnmCD.hdc, lpnmCD.rc)
                }

                RoundRect(lpnmCD.hdc, lpnmCD.rc.left, lpnmCD.rc.top, lpnmCD.rc.right, lpnmCD.rc.bottom, corner, corner)
                DeleteObject(rcRgn)

                if first
                    first := 0

                SetWindowPos(this.hwnd, 0,,,,, 0x4043)

                return CDRF_NOTIFYPOSTPAINT
            }}
            
            return CDRF_DODEFAULT
        }

        RgbToBgr(color) => (IsInteger(color) ? ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16) : NUMBER(RegExReplace(STRING(color), "Si)c?(?:0x)?(?<R>\w{2})(?<G>\w{2})(?<B>\w{2})", "0x${B}${G}${R}")))

        CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('Gdi32\CreateRoundRectRgn', 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')

        CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        ColorHex(clr) => Number((!InStr(clr, "0x") ? "0x" : "") clr)

        DrawFocusRect(hDC, lprc) => DllCall("User32\DrawFocusRect", "ptr", hDC, "ptr", lprc, "int")

        GetStockObject(fnObject) => DllCall('Gdi32\GetStockObject', 'int', fnObject, 'ptr')

        InflateRect(lprc, dx, dy) => DllCall("User32\InflateRect", "ptr", lprc, "int", dx, "int", dy, "int")

        SetWindowPos(hWnd, hWndInsertAfter, X := 0, Y := 0, cx := 0, cy := 0, uFlags := 0x40) => DllCall("User32\SetWindowPos", "ptr", hWnd, "ptr", hWndInsertAfter, "int", X, "int", Y, "int", cx, "int", cy, "uint", uFlags, "int")

        SetDCPenColor(hdc, crColor) => DllCall('Gdi32\SetDCPenColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetDCBrushColor(hdc, crColor) => DllCall('Gdi32\SetDCBrushColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetWindowRgn(hWnd, hRgn, bRedraw) => DllCall("User32\SetWindowRgn", "ptr", hWnd, "ptr", hRgn, "int", bRedraw, "int")

        DeleteObject(hObject) {
            DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')
        }

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

; Example
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
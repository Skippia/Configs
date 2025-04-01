; Custom Shortcuts using Win key

; Close active window with Win + Q
#q::WinClose, A

; Fold (minimize) active window with Win + A
#a::WinMinimize, A

; Open Ubuntu terminal with Win + Enter
#Enter::Run, wsl.exe

; Open File Explorer with Win + E (this is the default behavior, so you don't need to redefine it)
; #e::Run explorer.exe

; Switch keyboard language with Alt + `
!`::Send, {LWin Down}{Space}{LWin Up}

; Alternatively, if your keyboard has a specific `ё` key
; !ё::Send, {LWin Down}{Space}{LWin Up}

^PgUp::
Send, —
return

#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

Gui New, -MinimizeBox -MaximizeBox
Gui Font, s20
Gui Add, Text, x8 y8 w465 h38 +0x1 +0x200, Am I infected?
Gui Font
Gui Font, s72 Bold cBlack, Arial
Gui Add, Text, x8 y48 w463 h101 +0x1 +0x200 vResult, WAIT
Gui Font
Gui Add, Text, x8 y152 w465 h23 +0x1 +0x200, If it says YES`, you must reinstall Discord. This may not detect all versions of AnarchyGrabber.
Gui Add, Text, x8 y176 w465 h23 +0x1 +0x200, AnarchyGrabber Detector by Blackbeard Softworks
Gui Show, w481 h208, AnarchyGrabber Detector
GoSub, GetPath
Return

GuiEscape:
GuiClose:
    ExitApp

; End of the GUI section

GetPath:
; Get where the Discord is running from
Process, Exist, discord.exe
if (ErrorLevel != 0) {
DiscordPath := GetModuleFileNameEx(ErrorLevel)
GoSub, DetectAnarchy
return
}
else MsgBox, 16, Error, Discord is not running. Please unplug the network cable or disconnect Wi-Fi, then start Discord.`nThis program cannot get a path to the correct file without it.`n`nIf your client is infected and you don't disconnect the network`, it may steal your account info.
ExitApp
Return

DetectAnarchy:
; Get a path to the discord_desktop_core folder, which may have a number appended
SplitPath, DiscordPath,,DiscordDir
Loop, Files, %DiscordDir%\modules\discord_desktop_core*.*, D	
	tmpQ := A_LoopFileName
ModulePath := DiscordDir "\modules\" tmpQ "\discord_desktop_core\"

; Check for "4n4rchy" folder, if it exists, set the flag
AnarchyPath := ModulePath "\4n4rchy"
if !FileExist(AnarchyPath) {
	AnarchyFound := 0
}
else {
	AnarchyFound := 1
}

; Check for index.js tampering, it should be exactly 40 bytes long
FileGetSize, IndexSize, %ModulePath%index.js
if (IndexSize != 40) {
IndexTampered := 1
}
else IndexTampered := 0

; We're done now, return the results
GoSub, ShowResult
return

ShowResult:

; If it has two indicators, change the text to YES
if (AnarchyFound && IndexTampered){
	GuiControl, +cFF0000, Result
	GuiControl,, Result, YES
	return
}

; If it has one indicator, change the text to UNSURE
if (!AnarchyFound && IndexTampered)||(AnarchyFound && !IndexTampered){
	GuiControl, +cFFCC00, Result
	GuiControl,, Result, UNSURE
	return
}
; If it has no indicators, change the text to NO
else {
	GuiControl, +c00CC00, Result
	GuiControl,, Result, NO
	return
}

; End of program

; Get the full path to EXE file from PID (used to detect which folder Discord is running from)
GetModuleFileNameEx( p_pid ) ; by shimanov -  www.autohotkey.com/forum/viewtopic.php?t=9000
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME
   {
      MsgBox, This Windows version (%A_OSVersion%) is not supported.
      return
   }
   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
      return
   name_size = 255
   VarSetCapacity( name, name_size )
   result := DllCall( "psapi.dll\GetModuleFileNameEx" ( A_IsUnicode ? "W" : "A" )
                 , "uint", h_process, "uint", 0, "str", name, "uint", name_size )
   DllCall( "CloseHandle", h_process )
   return, name
}
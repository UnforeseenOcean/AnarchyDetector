#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

AnarchyAlert := "Not Found"
AnarchyBody := "Not Found"
AnarchyInject := "Not Found"
IndexAlert := "Normal"
IndexSize := 0

LogPath := A_ScriptDir "\Log-" A_YYYY "-" A_MM "-" A_DD "-" A_Hour "-" A_Min "-" A_Sec ".txt"

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

FileAppend, ========== LOG START ==========`n, %LogPath%
FileAppend, Diagnosis started at %A_Now%`n, %LogPath%

; Get where the Discord is running from
Process, Exist, discord.exe

if (ErrorLevel != 0) {
	DiscordPath := GetModuleFileNameEx(ErrorLevel)
	FileAppend, Discord Path: %DiscordPath%`n, %LogPath%
	GoSub, DetectAnarchy
	return
}
else {
	FileAppend, Program failed to detect Discord directory. Exiting.`n, %LogPath%
	FileAppend, ========== LOG END ==========`n, %LogPath%
	MsgBox, 16, Error, Discord is not running. Please unplug the network cable or disconnect Wi-Fi, then start Discord.`nThis program cannot get a path to the correct file without it.`n`nIf your client is infected and you don't disconnect the network`, it may steal your account info.
	ExitApp
	Return
}
Return 

DetectAnarchy:
; Get a path to the discord_desktop_core folder, which may have a number appended
SplitPath, DiscordPath,,DiscordDir
Loop, Files, %DiscordDir%\modules\discord_desktop_core*.*, D	
	tmpQ := A_LoopFileName
ModulePath := DiscordDir "\modules\" tmpQ "\discord_desktop_core\"
FileAppend, Module Folder Path: %ModulePath%`n`n, %LogPath%

; Check for any other files in the module folder
FileAppend, Module folder contains the following files.`n, %LogPath%
FileAppend, The folder should only contain 3 files: core.asar`, index.js`, and package.json.`n`n, %LogPath%
Loop, Files, %ModulePath%\*.*, FDR 
{
	CurrentFile := A_LoopFileName
	FileAppend, %CurrentFile%`n, %LogPath%
}

FileAppend, `n, %LogPath%


; Check for "4n4rchy" folder, if it exists, set the flag
FileAppend, Checking for "4n4archy" or "4n4rchy" folder...`n, %LogPath%
AnarchyPath := ModulePath "\4n4rchy"
AnarchyPath2 := ModulePath "\4n4archy"
if (FileExist(AnarchyPath)) || (FileExist(AnarchyPath2)) {
	AnarchyFound := 1
	AnarchyAlert := "DETECTED"
	FileAppend, Warning! AnarchyGrabber folder(s) were found!`n`n, %LogPath%
}
else {
	FileAppend, Folders not found. Moving on.`n`n, %LogPath%
	AnarchyFound := 0
}

; Check for index.js tampering, it should be exactly 40 bytes long
FileGetSize, IndexSize, %ModulePath%index.js

FileAppend, index.js size: %IndexSize% bytes. It should be 40 bytes.`n, %LogPath%

if (IndexSize != 40) {
	IndexTampered := 1
	IndexAlert := "TAMPERED"
	FileAppend, Warning! index.js has been tampered with!`n, %LogPath%
}
else { 
	IndexTampered := 0
	FileAppend, index.js does not seem to be tampered with.`n`n, %LogPath%
}
; We're done now, return the results

FileAppend, ========== LOG END ==========`n, %LogPath%
FileAppend, `n`n, %LogPath%
GoSub, ShowResult
return

ShowResult:

; If it has two indicators, change the text to YES
if (AnarchyFound && IndexTampered){
	GuiControl, +cFF0000, Result
	GuiControl,, Result, YES
	MsgBox, 16, Warning, Your Discord client has been infected with AnarchyGrabber.`nPlease uninstall Discord fully and reinstall it.`nDo not use a pre-downloaded installer. Go to the official site and redownload the installer.`nFor more information`, please refer to the log file: `n%LogPath%
	return
}

; If it has one indicator, change the text to UNSURE
if (!AnarchyFound && IndexTampered)||(AnarchyFound && !IndexTampered){
	GuiControl, +cFFCC00, Result
	GuiControl,, Result, UNSURE
	MsgBox, 48, Alert, Your Discord client has been modified in some way.`nPlease refer to the log file: `n%LogPath%
	return
}
; If it has no indicators, change the text to NO
else {
	GuiControl, +c00CC00, Result
	GuiControl,, Result, NO
	MsgBox, 64, Alert, Your Discord client seems to be fine.`nFor more information, please refer to the log file: `n%LogPath%
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

' Get the path specified as an argument
Dim argumentPath
argumentPath = WScript.Arguments.Item(0)

' Prompt the user to select a directory path
Dim shell
Set shell = CreateObject("Shell.Application")
Dim userPath
Set userPath = shell.BrowseForFolder(0, "Select directory path", 0, 0)
If userPath Is Nothing Then
    WScript.Echo "No directory path selected. Exiting script."
    WScript.Quit
End If

' Append the last directory from the argument path to the user-selected path
Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
Dim argumentDir
argumentDir = fso.GetFolder(argumentPath).Name
Dim newPath
newPath = userPath.Self.Path & "\" & argumentDir
Set userPath = shell.NameSpace(newPath)

MsgBox newPath
MsgBox argumentPath
' Create a symbolic link from the user-selected directory to the argument path
Dim wshShell
Set wshShell = CreateObject("WScript.Shell")
Dim cmd
cmd = "mklink /d """ & newPath & """ """ & argumentPath & """"
MsgBox cmd
wshShell.Run cmd, 0, True

' Display a success message
WScript.Echo "Symbolic link created from " & newPath & " to " & argumentPath & "."

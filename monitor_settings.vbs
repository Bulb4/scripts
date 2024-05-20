Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run("C:\Windows\System32\rundll32.exe display.dll,ShowAdapterSettings 0")

WScript.Sleep 200

WshShell.SendKeys "+{TAB}"
WshShell.SendKeys "{RIGHT}"

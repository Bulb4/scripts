add-type @' 
using System.Runtime.InteropServices; 
namespace Win32 {
	public class user32 {
		[DllImport("user32.dll", CharSet=CharSet.Auto)] 
		public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
	}
}
'@

[Win32.user32]::SystemParametersInfo(20, 0, $args[0], 3)

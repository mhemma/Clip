Add-Type -memberDefinition @'
[DllImport("user32.dll")] 
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow); 
'@ -name Win32ShowWindowAsync -namespace Win32Functions

#minimize window
[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 2)

#restore window
#[Win32Functions.Win32ShowWindowAsync]::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 10)

Start-Process -FilePath "C:\Windows\system32\notepad.exe"

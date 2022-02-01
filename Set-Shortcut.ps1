# Function
# Update shortcut with correct arguments
# WshShellClass wsh = new WshShellClass();
# IWshRuntimeLibrary.IWshShortcut shortcut = wsh.CreateShortcut(
#     Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "\\shorcut.lnk") as IWshRuntimeLibrary.IWshShortcut;
# shortcut.Arguments = "c:\\app\\settings1.xml";
# shortcut.TargetPath = "c:\\app\\myftp.exe";
# shortcut.WindowStyle = 1; 
# shortcut.Description = "my shortcut description";
# shortcut.WorkingDirectory = "c:\\app";
# shortcut.IconLocation = "specify icon location";
# shortcut.Save();

function Set-Shortcut($shortcutLocation, $shortcutArguments) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
    $shortcut.Arguments = $shortcutArguments
    $Shortcut.Save()
}

# Variables
$shortcutLocation = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Notepad++.lnk"
# Get accounts from text file.
$accounts = Get-Content -raw .\accounts.txt | ConvertFrom-StringData
# Update shortcut arguments if matching computername
$shortcutArguments = foreach($account in $accounts){
    Set-Shortcut $shortcutLocation $account.$env:COMPUTERNAME
}


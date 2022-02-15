Start-Transcript -Path C:\Windows\Logs\KioskNotepadEnroll.log

# Set variables
$kioskNotepad = "kiosknotepad"
$scriptFolderPath = "C:\Windows\Tasks\Kiosk"
$scriptNotepadAutologon = "KioskNotepadAutologon.ps1"
$scriptLockWorkstation = "LockWorkstation.ps1"

# Create local kioskuser.
Remove-LocalUser -Name $kioskNotepad -ErrorAction SilentlyContinue
$password = ConvertTo-SecureString "Pass" -AsPlainText -Force
New-LocalUser -Name $kioskNotepad -Password $Password -UserMayNotChangePassword -PasswordNeverExpires
Add-LocalGroupMember -Group "Users" -Member $kioskNotepad 

# Copy scripts.
New-Item -Path $scriptFolderPath -ItemType Directory -Force
Copy-Item ".\$scriptNotepadAutologon" -Destination "$scriptFolderPath" -Force
Copy-Item ".\$scriptLockWorkstation" -Destination "C:\Windows\SoftwareDistribution" -Force

#************************* kiosknotepad autologon task *********************************
# Delete, if task already exist.
$taskName1 = "Autologon $kioskNotepad"
Unregister-ScheduledTask -TaskName $taskName1 -Confirm:$false -ErrorAction SilentlyContinue

# Create a new task action.
$taskAction1 = New-ScheduledTaskAction `
    -Execute 'powershell.exe ' `
    -Argument "-ExecutionPolicy Bypass -File $scriptFolderPath\$scriptNotepadAutologon"
$taskAction1

# Register the scheduled task.
$taskUsername = "System"
$taskDescription1 = "Autologon $kioskNotepad"
$taskTrigger1 = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask `
    -TaskName $taskName1 `
    -Action $taskAction1 `
    -Trigger $taskTrigger1 `
    -User $taskUsername `
    -RunLevel Highest `
    -Description $taskDescription1

# Run the scheduled task.
Start-Sleep 1
Get-ScheduledTask -TaskName $taskName1 | Start-ScheduledTask
#****************************************************************************************


#************************* Lock workstation task *********************************
# Delete, if task already exist.
$taskName2 = "Lock workstation"
Unregister-ScheduledTask -TaskName $taskName2 -Confirm:$false -ErrorAction SilentlyContinue

# Create a new task action.
$taskAction2 = New-ScheduledTaskAction `
    -Execute 'powershell.exe ' `
    -Argument "-ExecutionPolicy Bypass -File C:\Windows\SoftwareDistribution\$scriptLockWorkstation"
$taskAction2

# Register the scheduled task.
$taskDescription2 = "Lock workstation"
$taskTrigger2 = New-ScheduledTaskTrigger -AtLogon
$taskPrincipal2 = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users" -RunLevel Highest
Register-ScheduledTask `
    -TaskName $taskName2 `
    -Action $taskAction2 `
    -Trigger $taskTrigger2 `
    -Principal $taskPrincipal2 `
    -Description $taskDescription2

# Allow users to run this task
$scheduler = New-Object -ComObject "Schedule.Service"
$scheduler.Connect()
$task = $scheduler.GetFolder("\").GetTask($taskName2)
$sec = $task.GetSecurityDescriptor(0xF)
$sec = $sec + ‘(A;;GRGX;;;AU)’
$task.SetSecurityDescriptor($sec, 0)

#****************************************************************************************


# Skip first logon animation.
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System","EnableFirstLogonAnimation",0,[Microsoft.Win32.RegistryValueKind]::DWord)

# Skip OOBE privacy settings.
[Microsoft.Win32.Registry]::SetValue("HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\OOBE","DisablePrivacyExperience",1,[Microsoft.Win32.RegistryValueKind]::DWord)

Start-Sleep 1
Restart-Computer

Stop-Transcript

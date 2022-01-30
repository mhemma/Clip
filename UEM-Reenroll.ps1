Start-Transcript -Path "$env:windir\logs\AirwatchEnroll.log" -ErrorAction SilentlyContinue -Verbose

$MSIPath = "\\UNCPath\InstallShare\AirwatchAgent.msi"
$uninstall = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like "*Intelligent Hub*"}
$install = @"
Start-Process $env:TEMP\AirwatchAgent.msi -Wait -ArgumentList "/quiet ENROLL=Y IMAGE=N SERVER=ds LGNAME=WINDOWS USERNAME=stage PASSWORD=*****"
"@

# Copy installation to temp
Copy-Item $MSIPath -Destination $env:TEMP

if($uninstall){
    $uninstall
    Write-Output "Uninstalling!"
    $uninstallResult = $uninstall.Uninstall()
    sleep 10
    if($uninstallResult.ReturnValue -eq 0){
        Write-OutPut "Uninstall complete!"
        Write-Output "Installing!"
        Invoke-Expression $install
        Check-EnrollmentStatus
    } else {
        Write-Output "Uninstall failed!"
        exit
    }
} else {
    Write-Output "Installing!"
    Invoke-Expression $install
    Check-EnrollmentStatus
}


function Check-EnrollmentStatus{
    $counter = 0
    $wait = 24
    while($counter -lt $wait){
        try{
        $isCompleted = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\AIRWATCH\EnrollmentStatus" -Name "Status" -ErrorAction SilentlyContinue
        }catch{
        }
        if($isCompleted -eq "Completed"){
            Write-Output "Device successfully enrolled!"
            return
        } elseif($counter -ge ($wait -1)){
            Write-Output "Device enrollment not completed!"
            return
        }
    sleep 10
    $counter++
    Write-Output "Checking enrollment status!"
    }
}

Stop-Transcript -ErrorAction SilentlyContinue

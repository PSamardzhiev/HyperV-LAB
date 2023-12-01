#VARS Definition
$sourcevhd = "Win2012R2.vhdx"
$targetfolder = "D:\LVMs\Hyper-V\vlab\"

$LTVM = "vTemplate"
$LCVM1 = "LABDC"
$LCVM2 = "LABC1"
$LCVM3 = "LABC2"

$drivepath = `
    "D:\Software\ISOs Store\Windows OS Releases\WS Releases\WS2K12R2.iso"
$switch = "natVSW"

#checks if working directory exists, if not creates it and sets the shell context
if (!(Test-Path $targetfolder)) {
    try {
    Write-Host "'$targetfolder' cannot be found, the script will try to create it"
    New-Item -ItemType Directory -Path $targetfolder
    Set-Location $targetfolder 
    }
    catch {
        Write-Host "The path --> '$targetfolder' cannot be created, please try agian..."
        Start-Sleep 2
        break
    }
}
else { 
    Write-Host "The path --> '$targetfolder' exists, setting the shell context.."
    Start-Sleep 2
    Set-Location $targetfolder
}

#check and configure networking part:
if (-not (Get-VMSwitch -Name $switch)) {
    New-VMSwitch -SwitchType Internal -Name $switch
    New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 24 -InterfaceIndex `
    (Get-NetAdapter | Where-Object { $_.Name -like "*natVSW*" }).ifIndex
    New-NetNat -Name $switch -InternalIPInterfaceAddressPrefix 192.168.100.0/24
    Write-Host "switch $switch created"

}
else { 
    Write-Host "switch $switch already exists"
}
#scriptblock to check if VHDX exists

if (!(Test-Path -Path .\$sourcevhd)) {
    Write-Host "LAB VHDX Disk is not present, creting the disk now..."
    Start-Sleep -Seconds 5
    New-VHD -path .\$sourcevhd -SizeBytes 120GB -Dynamic -Verbose
}
else { 
    Write-Host "The VHDX already exists, removing the VHDX now and re-creating it"
    if ((Get-VM -Name $LTVM).State -like 'Running') {
        Stop-VM -Name $LTVM -Force
        Remove-VM -Name $LTVM -Force
        Remove-Item -Path .\$sourcevhd -Force
    }
    else {
        Remove-VM -Name $LTVM -Force
        Remove-Item -Path .\$sourcevhd -Force
        New-VHD -path .\$sourcevhd -SizeBytes 120GB -Dynamic
    }
}

Write-Host "VDHX Created, press any key to continue..."
Pause

New-VM -Name $LTVM -Path .\ -VHDPath .\$sourcevhd -SwitchName $switch -Generation 2 | `
    Set-VMMemory -DynamicMemoryEnabled $true `
    -MaximumBytes 2GB -MinimumBytes 512MB -StartupBytes 1.5GB

Set-VM -Name $LTVM `
    -AutomaticCheckpointsEnabled $false -EnhancedSessionTransportType HvSocket `
    -CheckpointType Production -PassThru

Add-VMDvdDrive -VMName $LTVM -Path $drivepath
Get-VMDvdDrive -VMName $LTVM | ForEach-Object { Set-VMFirmware -VMName $LTVM -FirstBootDevice $_ }

if ((get-vm -Name $LTVM).State -eq 'Off') {
    Write-Host "VM $LTVM is not running attempting to boot the VM..."
    Start-Sleep -Seconds 5
    Start-VM -Name $LTVM
    vmconnect.exe localhost $LTVM
}
else {
    Write-Host "$LTVM is already in running state"
    Start-Sleep -Seconds 5
    vmconnect.exe localhost $LTVM
}

Clear-Host

Start-Sleep 5
# In the VM itself, created from the above commands, login and perform the following actions:
# open powershell as administrator and paste the below:
# set-location C:\Windows\system32\Sysprep
# .\sysprep.exe /generalize /oobe /shutdown
Write-Host "if your main $LTVM machine is fully configured and SYSPREPED press any key to shut it down and create differencing disks"
Pause
Stop-VM -VMName $LTVM -Force
Write-Host "please wait 10 seconds cool down period"
Start-Sleep -Seconds 10
remove-vm -Name $LTVM -Force

New-VHD -Path ($targetfolder + $LCVM1 + ".vhdx") -ParentPath .\$sourcevhd -Differencing
New-VHD -path ($targetfolder + $LCVM2 + ".vhdx") -ParentPath .\$sourcevhd -Differencing
New-VHD -path ($targetfolder + $LCVM3 + ".vhdx") -ParentPath .\$sourcevhd -Differencing


new-vm -Name $LCVM1 -Path .\ -VHDPath .\$LCVM1.vhdx -SwitchName $switch -Generation 2  | `
set-vmmemory -DynamicMemoryEnabled $true `
-MaximumBytes 2GB -MinimumBytes 512MB -StartupBytes 1.5GB

new-vm -Name $LCVM2 -Path .\ -VHDPath .\$LCVM2.vhdx -SwitchName $switch -Generation 2 | `
set-vmmemory -DynamicMemoryEnabled $true `
-MaximumBytes 2GB -MinimumBytes 512MB -StartupBytes 1.5GB

new-vm -Name $LCVM3 -Path .\ -VHDPath .\$LCVM3.vhdx -SwitchName $switch -Generation 2 | `
set-vmmemory -DynamicMemoryEnabled $true `
-MaximumBytes 2GB -MinimumBytes 512MB -StartupBytes 1.5GB

Set-VM -Name $LCVM1 `
    -AutomaticCheckpointsEnabled $false -EnhancedSessionTransportType HvSocket `
    -CheckpointType Production -PassThru

Set-VM -Name $LCVM2 `
-AutomaticCheckpointsEnabled $false -EnhancedSessionTransportType HvSocket `
-CheckpointType Production -PassThru

Set-VM -Name $LCVM3 `
-AutomaticCheckpointsEnabled $false -EnhancedSessionTransportType HvSocket `
-CheckpointType Production -PassThru

(Get-VM -Name "LAB*").Name | ForEach-Object { 
    Start-VM -Name $_
    vmconnect.exe localhost $_
    Start-Sleep -Seconds 3
}
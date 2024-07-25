Import-Module ActiveDirectory

$inactiveDays = 90 #<-- Change the number of days as per your needs
$thresholdDate = (Get-Date).AddDays(-$inactiveDays)

[array]$usersToDisable = Get-ADUser -Filter {(LastLogonDate -lt $thresholdDate) -and (Enabled -eq $true)} -Property LastLogonDate

foreach ($user in $usersToDisable) {
    Disable-ADAccount -Identity $user.SamAccountName
    Write-Host "Disabled user: $($user.SamAccountName)"
    Write-Host "User $($user.SamAccountName) last seen on $($user.LastLogonDate)"
}

Write-Host "Script execution completed."
Write-Host "Total users disabled $($usersToDisable.Count)"

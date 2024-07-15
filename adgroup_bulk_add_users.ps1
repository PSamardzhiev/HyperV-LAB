$adgroup = "CloudUsers" #Change the group name if required
$csvfile = "C:\temp\users.csv" #change the CSV file location if required

[array]$users = Import-Csv -Path $csvfile

if (-not (Get-ADGroup -Filter {Name -Like $adgroup} -ErrorAction SilentlyContinue)) {
    Write-Host "$adgroup is not found in your domain, the script will now try to create it"
    Start-Sleep 1
    try {
        New-ADGroup -Name $adgroup -GroupScope DomainLocal -GroupCategory Security -Description $adgroup -DisplayName $adgroup
        Write-Host "The group $adgroup is now created!, below you can find useful information about the group"
        Get-ADGroup -Identity $adgroup
    } catch {
        Write-Host "The script was not able to create $adgroup, it will now exit"
        exit
    }
}

foreach ($user in $users) {
    $sam = $user.samaccountname
    if (!(Get-ADUser -Filter {samaccountname -eq $sam} -ErrorAction SilentlyContinue)) {
        Write-Host "$sam is not found in your active directory" | Out-File c:\temp\ad_group_members_log.txt -Append
        Start-Sleep 1
        continue
    } else {
        Add-ADGroupMember -Identity $adgroup -Members $sam
        Write-Host "$($user.samaccountname) is now member of the $adgroup group"
        Start-Sleep 1
    }
}

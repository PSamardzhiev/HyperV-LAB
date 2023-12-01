# Specify the path to the CSV file 
#you can change your path based on your CSV location

$csvPath = "C:\temp\users.csv"

# Import user data from CSV
$userData = Import-Csv $csvPath

#check of OU exists
Clear-Host
$ouName = "lab_import"
$rootDN = (Get-ADDomain).DistinguishedName
$RootDNOUPath = ("OU=" + "$ouName," + $rootDN)
$ouExists = Get-ADOrganizationalUnit -Filter {Name -eq $ouName} -SearchBase $rootDN -ErrorAction SilentlyContinue

if (-not $ouExists) {
    try {
        New-ADOrganizationalUnit -Name $ouName -Path $rootDN `
        -ErrorAction Stop `
        -ProtectedFromAccidentalDeletion $false

        Write-Host "OU '$ouName' created successfully."
        Start-Sleep 3
        Clear-Host
    }
    catch {
        Write-Host "Error creating OU '$ouName': $_"
        Start-Sleep 5
        clear
    }
}
else {
    Write-Host "OU '$ouName' already exists. Skipping creation."
}


# Iterate through each user in the CSV and create an Active Directory user
foreach ($user in $userData) {
    $firstName = $user."First Name"
    $lastName = $user."Last Name"
    $sam = ($firstName + "." + $lastName)
    $jobTitle = $user."Job Title"
    $officePhone = $user."Office Phone"
    $employeeID = $user."Employee ID"
    $email = $user."Email Address"
    $description = $user."Description"
    $enabled = $user."Enabled"
    $password = $user."Password"

    $enabled = $enabled -eq "TRUE"
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

    try {
        # Check if the user already exists
        if (-not (Get-ADUser -Filter {SamAccountName -eq $sam})) {
            # AD User creation scriptblock
            New-ADUser -SamAccountName $sam -UserPrincipalName $email `
                -GivenName $firstName -Surname $lastName -Title $jobTitle `
                -OfficePhone $officePhone -EmployeeID $employeeID -EmailAddress $email `
                -Description $description -Enabled $enabled -AccountPassword $securePassword `
                -DisplayName "$lastName, $firstName" -Name "$firstName $lastName" -Path $RootDNOUPath `
                 -ChangePasswordAtLogon $true

            Write-Host "User $sam created successfully." 
            write-host "The user will be required to change his password at logon, the initial login password is $Password"
            Start-Sleep 1
        } else {
            Write-Host "User $sam already exists. The Script will skip this user!."
        }
    }
    catch {
        Start-Sleep 5
        Write-Host "Error creating user: $_"
    }
}

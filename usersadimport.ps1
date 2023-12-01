# Specify the path to the CSV file 
#you can change your path based on your CSV location

#define your variables below:
$tmpdir = "C:\temp\"
$csvPath = "C:\temp\users.csv"
$ouName = "lab_import"
$rootDN = (Get-ADDomain).DistinguishedName
$RootDNOUPath = ("OU=" + "$ouName," + $rootDN)
$ouExists = Get-ADOrganizationalUnit -Filter {Name -eq $ouName} -SearchBase $rootDN -ErrorAction SilentlyContinue
$userData = Import-Csv $csvPath


if (!(Test-Path $tmpdir -ErrorAction SilentlyContinue)) {
    Write-Host "The script is unable to find the required path -> '$tmpdir'"
    Start-Sleep 10
    Write-Host "The script will try to create the following path -> '$tmpdir'"
    Start-Sleep 10
    try {
    New-Item -ItemType Directory -Path $tmpdir
    }
    catch {
        Write-Host "the directory '$tmpdir' cannot be created $_"
        Start-Sleep 10
    }
}
if (!(Test-Path $csvPath -ErrorAction Stop)) {
    Write-Host "The script cannot find the users.csv file located at '$tmpdir'"
    Start-Sleep 3
    Write-Host "Please copy the CSV file which you want to import in Active Directory and rename it to users.csv"
    Start-Sleep 5
    break

}

# Import user data from CSV


#check of OU exists
Clear-Host

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
        Clear-Host
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
    #$password = $user."Password" password defined below in a variable for easier use
    $PSDString = 'P@ssw0rd2023'

    $enabled = $enabled -eq "TRUE"
    $securePassword = ConvertTo-SecureString $PSDString -AsPlainText -Force

    #vars for logfile
    $log_user_exists = "User $sam already exists. The Script will skip this user!."
    $log_user_created = "User $sam created successfully with password $PSDString. This password needs to be changed!" 

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

            Write-Host $log_user_created
            $log_user_created | Out-File $tmpdir\created_users.log -Append
            Start-Sleep 1

        } else {
            Write-Host "$log_user_exists"
            $log_user_exists | Out-File -FilePath $tmpdir\existing_users.log -Append
            Start-Sleep 1
        }
    }
    catch {
        Start-Sleep 5
        Write-Host "Error creating user: $_"
    }
}

# Specify the path to the CSV file 
#you can change your path based on your CSV location

#define your variables below:
$filename = "users.csv"
$tmpdir = "C:\temp\"
$csvPath = ($tmpdir+$filename)
$ouName = "lab_import"
$rootDN = (Get-ADDomain).DistinguishedName
$RootDNOUPath = ("OU=" + "$ouName," + $rootDN)
$ouExists = Get-ADOrganizationalUnit -Filter {Name -eq $ouName} -SearchBase $rootDN -ErrorAction SilentlyContinue

#Scriptblock for data import pre-checks
Write-Host "Starting data import pre-check tasks..."
Start-Sleep 2

if (!(Test-Path $tmpdir -ErrorAction Ignore)) {
    Write-Host "The script is unable to find the required path --> '$tmpdir'"
    Start-Sleep 10
    Write-Host "The script will try to create the following path --> '$tmpdir'"
    Start-Sleep 10
    try {
    New-Item -ItemType Directory -Path $tmpdir
    }
    catch {
        Write-Host "the directory '$tmpdir' cannot be created $_"
        Start-Sleep 10
    }
}
if (!(Test-Path $csvPath -ErrorAction SilentlyContinue)) {
    Write-Host "The script cannot find the --> $filename file located at --> '$tmpdir'"
    Start-Sleep 3
    Write-Host "To Fix this please perform the following actions:"
    Write-Host "Copy the CSV file which you want to import in Active Directory to --> '$tmpdir'"
    Start-Sleep 3
    Write-Host "Rename the file to --> $filename"
    start-Sleep 3
    write-Host "The whole Source path should look like this --> '$csvPath'"
    Start-Sleep 5
    break
}

#Import the Source CSV file in $userData array

[array]$userData = Import-Csv $csvPath -ErrorAction SilentlyContinue
Write-Host "Importing data from --> '$csvPath'"
#check if target OU exists
Clear-Host

if (-not $ouExists) {
    try {
        New-ADOrganizationalUnit -Name $ouName -Path $rootDN `
        -ErrorAction Stop `
        -ProtectedFromAccidentalDeletion $false

        Write-Host "Target OU --> '$ouName' created successfully."
        Start-Sleep 3
        Clear-Host
    }
    catch {
        Write-Host "Error creating Target OU --> '$ouName': $_"
        Start-Sleep 5
        Clear-Host
    }
}
else {
    Write-Host "Target OU --> '$ouName' already exists. `n Skipping creation. `n"
    start-Sleep 3
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
    $enabled = ($user."Enabled").ToLower()
    #$password = $user."Password" password defined below in a variable for easier use
    $PSDString = 'P@ssw0rd2023'
    $UPN = ($firstName + "." + $lastName + "@" + (get-ADDomain).DNSRoot)
    
    if ($enabled -eq "true" -or $enabled -eq "false") {
    $enabled = [System.Convert]::ToBoolean($enabled)
    }
    else {
        Write-Host "There is an issue with --> $sam in the CSV File"
        Write-Host "The Field Enabled should be TRUE OR FALSE"
        Write-Host "$sam will be created but disabled!"`n
        start-sleep 7
        $enabled = "false"
        $enabled = [System.Convert]::ToBoolean($enabled)
    }
    $securePassword = ConvertTo-SecureString $PSDString -AsPlainText -Force

    #vars for logfile
    $log_user_exists = "User --> $sam already exists. `n The Script will skip this user!. `n User AD Enabled Status: $enabled"
    $log_user_created = "User --> $sam created successfully with password $PSDString and AD Enabled Status: $enabled. `n This password needs to be changed! `n" 

    try {
        # Check if the user already exists
        if (-not (Get-ADUser -Filter {SamAccountName -eq $sam})) {
            # AD User creation scriptblock
            New-ADUser -SamAccountName $sam -UserPrincipalName $UPN `
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
Write-Host "======================"
Write-Host "Total number of users located in --> "$RootDNOUPath":`n:$((Get-ADUser -Filter * -SearchBase "$RootDNOUPath").Count)"
Write-Host "======================"
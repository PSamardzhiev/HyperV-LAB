
# Hyper-V Lab Setup Script
## labsetup.ps1 ##
## Overview

This PowerShell script automates the setup and configuration of a lab environment in Hyper-V. 
The script is designed to create a virtual switch, handle networking configurations, manage VHDX files, and create virtual machines with specific settings.
It's particularly useful for setting up a Windows 2012 R2 virtual machine as a template and creating differencing disks for additional VMs.
For the complete LAB Topology check HyperV-LAB.pdf file in this repository.

## LAB Topology - High level design (HLD)
![alt text](https://github.com/PSamardzhiev/HyperV-LAB/blob/main/topology.jpg)


## Prerequisites

- **Hyper-V Installed:** Ensure that Hyper-V is installed and configured on your Windows system.
- **PowerShell:** Run the script in a PowerShell environment.

## Instructions

1. **Clone Repository:**
   ```bash
   git clone https://github.com/PSamardzhiev/HyperV-LAB.git
   cd HyperV-LAB

2. **Configure Variables:**

Open the script and modify the variables at the beginning of the file ($sourcevhd, $targetfolder, etc.) according to your requirements.
Run the Script:

Execute the script in a PowerShell environment.


# Active Directory User Import Script

This PowerShell script is designed to automate the process of importing user data from a CSV file into Active Directory. It creates new users based on the information provided in the CSV file and performs various pre-checks to ensure a smooth import process.

## Prerequisites

Before running the script, ensure that you have the following:

- PowerShell installed on your machine.
- Sufficient permissions to create Organizational Units (OU) and users in Active Directory.
- A CSV file containing user data with the required fields (First Name, Last Name, Job Title, Office Phone, Employee ID, Email Address, Description, Enabled).

## Configuration

1. **CSV File Path**: Update the `$filename` variable with the name of your CSV file, and `$tmpdir` with the desired path where the script will look for the CSV file.

   ```powershell
   $filename = "users.csv"
   $tmpdir = "C:\temp\"

Target OU Configuration: Modify the $ouName variable to set the name of the target Organizational Unit (OU) where the new users will be created.

$ouName = "lab_import"
Usage
Run the script in a PowerShell environment. The script will perform the following tasks:

Check and create the specified directory if it doesn't exist.
Verify the presence of the CSV file in the specified path.
Create the target OU if it doesn't already exist.
Iterate through each user in the CSV and create corresponding Active Directory users.
Log the creation or skipping of users in separate log files.
Monitor the script's output for any error messages or notifications during the user creation process.

Important Notes
The script assumes a specific structure in the CSV file with fields like "First Name," "Last Name," etc. Ensure that your CSV file adheres to this structure.
The default password for newly created users is set to 'P@ssw0rd2023'. You may need to modify this based on your organization's password policy.
Troubleshooting
If you encounter issues during the script execution, refer to the error messages displayed in the console for troubleshooting. Additionally, check the log files created in the specified directory for more detailed information.

Note: Always review and understand the script before execution, especially if it involves making changes to your Active Directory.



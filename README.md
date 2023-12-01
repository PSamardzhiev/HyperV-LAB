# Hyper-V Lab Setup Script
## labsetup.ps1 ##
## Overview

This PowerShell script automates the setup and configuration of a lab environment in Hyper-V. 
The script is designed to create a virtual switch, handle networking configurations, manage VHDX files, and create virtual machines with specific settings.
It's particularly useful for setting up a Windows 2012 R2 virtual machine as a template and creating differencing disks for additional VMs.
For the complete LAB Topology check HyperV-LAB.pdf file in this repository.

## LAB Topology - High level design (HLD)
![LAB Topology](https://github.com/PSamardzhiev/HyperV-LAB/blob/main/topology.jpg)


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

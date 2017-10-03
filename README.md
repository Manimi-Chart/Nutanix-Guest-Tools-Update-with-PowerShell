# Nutanix-Guest-Tools-Update-with-PowerShell
The script was created to automate the upgrade of Nutanix Guest tools.  
With some organizations having hundreds or thousands of vms it becomes nearly impossible to upgrade them manually.

We use SCCM in conjuctions with this script.  SCCM checks versioning and runs the script.  However it can be run with other solutions.
It can also be run manually on a VM for testing.

To get started fill in your cluster name, username and password at the start of the script.

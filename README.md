# Nutanix-Guest-Tools-Update-with-PowerShell
This script was created to automate the upgrade of Nutanix Guest Tools.  With some organizations having hundreds or thousands of vms it becomes nearly impossible to upgrade them manually.

We use SCCM in conjuction with this script.  SCCM checks versioning and runs the script.  However, it can be run with other solutions. It can also be run manually on a VM for testing. Powershell must be Run-As-Administrator for the script to run without interaction.  The VM must also have a CD drive attached to it.

To get started fill in your cluster name, username and password at the start of the script. If you open Explorer to "This PC" you will be able to see the tools mount to the CD drive and then unmount when complete.

This has been tested and verified on Windows Server 2016.  It also works if the CD drive is set as a different drive other than the standard D:.

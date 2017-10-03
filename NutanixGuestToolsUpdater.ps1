###Enter your environment details here between quotes:
$clusterName = "" #Use FQDN or IP address.
$username = "" #Nutanix administrator level account required. If AD account, use the following pattern: username@domain.com
$password = ""
###End of personalization section.

###Setup Environment
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

###Variables for the API
$vmUuid = get-wmiobject Win32_ComputerSystemProduct  | Select-Object -ExpandProperty UUID #Gets VM UUID and sets to variable.
$portNumber = ":9440"
$mountUri = "https://$clusterName$portNumber/PrismGateway/services/rest/v1/vms/$vmUuid/guest_tools/mount/"
$unMountUri = "https://$clusterName$portNumber/PrismGateway/services/rest/v1/vms/$vmUuid/guest_tools/unmount/"
$passwordConversion = ConvertTo-SecureString -String "$password" -AsPlainText -Force #Converts password to secure string for API compatibility
$cred = New-Object Management.Automation.PSCredential ($username, $passwordConversion)
$Header = @{
"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username+":"+$passwordConversion ))}

###API Connection/Drive Mount
# Runs REST API command with required variables. Uses -credential to establish PowerShell connection.  Then passes header that also includes creds.  Nutanix API requires authentication with each API call.
Invoke-RestMethod -Credential $cred -ContentType "application/json" -Method Post -Uri $mountUri -Headers $Header

###Drive Mount verify and Update/Installation
# Sets variable of driveMounted and checkDrive.
$driveMounted = [System.IO.DriveInfo]::GetDrives() | Where-Object {$_.VolumeLabel -eq "NUTANIX_TOOLS" } | Select-Object -ExpandProperty Name
$checkDrive = 0
# While loop to wait for the drive to mount.  Exit script with error if fails.
While ($driveMounted -eq $null)
{
If ($checkDrive -le '15')
    {
    $checkDrive++
    Start-Sleep -s 1
    $driveMounted = [System.IO.DriveInfo]::GetDrives() | Where-Object {$_.VolumeLabel -eq "NUTANIX_TOOLS" } | Select-Object -ExpandProperty name
    }
Else
    {
    Throw "Drive not mounted!"
    [System.Environment]::Exit
    }
}

#Installs using Start-Process so that it will wait for the installation to finish. Sets install results variable.
$Installation = Start-Process -PassThru -FilePath "$driveMounted\setup.exe" -ArgumentList "/quiet ACCEPTEULA=yes /norestart" -Wait

###Drive Mount Cleanup/Exit
$checkDrive = 0
#While loop to allow time for guest tools to unmount automatically.  If it does not then will send unmount command after 30 seconds.
While ($driveMounted -ne $null)
{
If ($checkDrive -le '30')
    {
    $checkDrive++
    Start-Sleep -s 1
    $driveMounted = [System.IO.DriveInfo]::GetDrives() | Where-Object {$_.VolumeLabel -eq "NUTANIX_TOOLS" } | Select-Object -ExpandProperty name
    }
Else
    {
    Invoke-RestMethod -Credential $cred -ContentType "application/json" -Method Post -Uri $unMountUri -Headers $Header
    Break
    }
}
#Provides exit code for SCCM and Exits script.
Exit $Installation.ExitCode
# Purpose: Creates the "vzlab.local" backup DC
# Source: https://blogs.technet.microsoft.com/chadcox/2016/10/25/chads-quick-notes-installing-a-domain-controller-with-server-2016-core/
# Source2: https://github.com/StefanScherer/adfs2

param ([String] $ip)

$subnet = "10.10.6."
$domainname = "vzlab.local"
$newDNSServers = "10.10.6.100"
$serveruser = "vzlab\serveruser"


Write-Host "First, set DNS to DC to join the domain"
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match $subnet}
$adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}

$subnet = $ip -replace "\.\d+$", ""

if ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host 'Installing Pre-requisites and tools'
  Import-Module ServerManager
  Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter
  Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

  Write-Host 'Creating domain controller'
  # Disable password complexity policy
  secedit /export /cfg C:\secpol.cfg
  (gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
  secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY
  rm -force C:\secpol.cfg -confirm:$false

  # Set administrator password
  $computerName = $env:COMPUTERNAME
  $adminPassword = "Adm1npassw0rdsr00l"
  $adminUser = [ADSI] "WinNT://$computerName/Administrator,User"
  $adminUser.SetPassword($adminPassword)

  $PlainPassword = "Sup3rs3cr3tpassw0rd1" # "P@ssw0rd"
  $SecurePassword = ConvertTo-SecureString "Sup3rs3cr3tpassw0rd1" -AsPlainText -Force

  $secpassword = ConvertTo-SecureString "daP@ssw0rdRH4rd" -AsPlainText -Force
  $creds = New-Object System.Management.Automation.PSCredential ("vzlab\da", $secpassword)

  Install-ADDSDomainController  -DomainName "vzlab.local" -SafeModeAdministratorPassword $SecurePassword -Credential $creds

  # Set a AD User as admin for subsequent logins
  Add-LocalGroupMember -Group "Administrators" -Member $serveruser
}
# Purpose: Joins a Windows host to the windomain.local domain which was created with "create-domain.ps1".
# Source: https://github.com/StefanScherer/adfs2

# Set variables for re-use
$subnet = "10.10.6." # Attack Lab Subnet
$domainname = "vzlab.local"
$serverou = "ou=Servers,dc=vzlab,dc=local"
$workstationou = "ou=Workstations,dc=vzlab,dc=local"
$newDNSServers = "10.10.6.100"

$hostname = $(hostname)
$user = "vzlab.local\joiner"
$pass = ConvertTo-SecureString "JoinTheDomain1" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

Write-Host 'Join the domain'

Write-Host "First, set DNS to DC to join the domain"
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match $subnet}
$adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}

Write-Host "Now join the domain"

# Place the computer in the correct OU based on hostname
If ($hostname -match "server-") {
  Add-Computer -DomainName $domainname -credential $DomainCred -OUPath $serverou -PassThru
} ElseIf ($hostname -match "win10") {
  Write-Host "Adding Win10 to the domain. Sometimes this step times out. If that happens, just run 'vagrant reload win10 --provision'" #debug
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -OUPath $workstationou
} Else {
  Add-Computer -DomainName "windomain.local" -credential $DomainCred -PassThru
}

# Set Auto-Login

If ($hostname -match "server-") {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "serveruser"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "ServerPassword1"
} ElseIf ($hostname -match "win10") {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value "user1"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "Password1"
}
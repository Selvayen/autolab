# Purpose: Sets timezone to UTC, sets hostname, creates/joins domain.
# Source: https://github.com/StefanScherer/adfs2
$dc = 10.10.6.100
$bdc = 10.10.6.101

$box = Get-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name "ComputerName"
$box = $box.ComputerName.ToString().ToLower()

Write-Host "Setting timezone to Eastern"
c:\windows\system32\tzutil.exe /s "Eastern Standard Time"

if ($env:COMPUTERNAME -imatch 'vagrant') {

  Write-Host 'Hostname is still the original one, skip provisioning for reboot'

  Write-Host 'Install bginfo'
  . c:\vagrant\scripts\install-bginfo.ps1

  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} elseif ((gwmi win32_computersystem).partofdomain -eq $false) {

  Write-Host -fore red "Current domain is set to 'workgroup'. Time to join the domain!"

  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host 'Install bginfo'
    . c:\vagrant\scripts\install-bginfo.ps1
  } 

  if ($env:COMPUTERNAME -eq 'dc') {
    . c:\vagrant\scripts\create-domain.ps1 $dc
  } elseif ($env:COMPUTERNAME -eq 'bdc') {
    . c:\vagrant\scripts\create-backup-dc.ps1 $bdc
  } else {
    . c:\vagrant\scripts\join-domain.ps1
  }
  Write-Host -fore red 'Hint: vagrant reload' $box '--provision'

} else {

  Write-Host -fore green "I am domain joined!"

  if (!(Test-Path 'c:\Program Files\sysinternals\bginfo.exe')) {
    Write-Host 'Install bginfo'
    . c:\vagrant\scripts\install-bginfo.ps1
  }

  Write-Host 'Provisioning after joining domain'

  # $script = "c:\vagrant\scripts\provision-" + $box + ".ps1"
  # . $script
}

# Purpose: Sets up the Server and Workstations OUs

$domain = "vzlab"

Write-Host "Creating Server and Workstation OUs..."
Write-Host "Creating Servers OU..."
if (!([ADSI]::Exists("LDAP://OU=Servers,DC=$domain,DC=local")))
{
    New-ADOrganizationalUnit -Name "Servers" -Server "dc.vzlab.local"
}
else
{
    Write-Host "Servers OU already exists. Moving On."
}
Write-Host "Creating Workstations OU"
if (!([ADSI]::Exists("LDAP://OU=Workstations,DC=$domain,DC=local")))
{
    New-ADOrganizationalUnit -Name "Workstations" -Server "dc.vzlab.local"
}
else
{
    Write-Host "Workstations OU already exists. Moving On."
}
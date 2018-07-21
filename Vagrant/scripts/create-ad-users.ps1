# Create AD Users (Including DA)
# Source:  https://www.pdq.com/blog/add-users-to-ad-with-powershell

$UserList = Import-Csv -Path 'C:\temp\users.csv'

foreach ($User in $UserList) {

    $Attributes = @{

    Enabled = $true
    ChangePasswordAtLogon = $false

    UserPrincipalName = "$($User.First)@vzlabs.local"
    Name = "$($User.First)"
    SamAccountName = "$($User.First)"

    AccountPassword = "$($User.Password)" | ConvertTo-SecureString -AsPlainText -Force

    }

    New-ADUser @Attributes

    if ($($User.First) -match "da") {
        Add-ADGroupMember -Identity "Domain Admins" -Members $($User.First)
    }
}
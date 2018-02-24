# PowerShell
PowerShell scripts and tricks

# Usefull cmdlets
## Get list of PCs from AD group
 Get-ADComputer -Filter * -SearchBase "OU=Windows 10,OU=Computers,OU=,DC=,DC=net"
 | select -ExpandProperty Name
 
 or
 
 dsquery computer "OU=Windows 10,OU=Computers,OU=,DC=,DC=net" -o rdn
 
 ## Get list of users with local admin access
 Get-LocalGroupMember -name Administrators
 
 Get-LocalGroupMember -name Administrators |? {$_.ObjectClass -eq "Group"} | % {Get-ADGroupMember $_.name.Split('\')[1] -Recursive} | select Name,SamAccountName,objectClass

## Get AV status
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct  -ComputerName  $env:computername

## Set AV status
Set-WmiInstance -Path '\\HOSTNAME\root\SecurityCenter2:AntiVirusProduct.instanceGuid="{1006DC03-1FB1-9E52-7C81-F2FAB48962E3}"' -Argument @{productState="397312"}

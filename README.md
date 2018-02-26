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

## Autostart smtng

$taskName = "McAfee VSEp10 fix"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File "C:\Temp\test.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at startup"
Register-ScheduledTask -TaskName $taskName -InputObject $definition

Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue 

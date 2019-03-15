# PowerShell
PowerShell scripts and tricks

# Usefull cmdlets
## Filesystem
### Get hidden streams 
":$DATA" is normal. Everything else is not. 
```powershell
Get-Item -Path C:\path\* -Stream * | ?{$_.stream -notlike ":`$DATA"} | select FileName, Stream, Length
```

## It's alive!
```powershell
 Add-Type -AN System.Speech;[System.Speech.Synthesis.SpeechSynthesizer]::new().Speak("Kill all h
umans!")
```
## Windows Domain 
### Get list of PCs from AD group
```powershell
 Get-ADComputer -Filter * -SearchBase "OU=Windows 10,OU=Computers,OU=,DC=,DC=net"
 | select -ExpandProperty Name
```
 or
 ```powershell
 dsquery computer "OU=Windows 10,OU=Computers,OU=,DC=,DC=net" -o rdn`
 ```
 
 ### Get list of users with local admin access
 ```powershell
 Get-LocalGroupMember -name Administrators
 ```
 ```powershell
 Get-LocalGroupMember -name Administrators |? {$_.ObjectClass -eq "Group"} | % {Get-ADGroupMember $_.name.Split('\')[1] -Recursive} | select Name,SamAccountName,objectClass
 ```
 
 ### Get KRBTGT info
```powershell
Get-ADUser -Filter{SamAccountName -like "krbtgt*"} -Properties PasswordLastSet,msDS-KeyVersionNumber, msDS-KrbTgtLinkBl
```
note: krbtgt_XXX accoutns are owned by RODC, KeyVersion == 1 means password was never changed

## Get AV status
```powershell
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct  -ComputerName  $env:computername`
```

## Set AV status
```powershell
Set-WmiInstance -Path '\\HOSTNAME\root\SecurityCenter2:AntiVirusProduct.instanceGuid="{1006DC03-1FB1-9E52-7C81-F2FAB48962E3}"' -Argument @{productState="397312"}
```

## Autostart smtng

$taskName = "McAfee VSEp10 fix"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File "C:\Temp\test.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at startup"
Register-ScheduledTask -TaskName $taskName -InputObject $definition

Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue 


## Mail investigations
### Retrieve all rules - high level
Get-Mailbox -ResultSize unlimited | Get-InboxRule -ErrorAction:SilentlyContinue | format-table -Autosize MailboxOwnerID,name,from,redirectto,ForwardTo > c:\Forwarding_Rules.csv	
### Retrieve all rules - detailed
Get-Mailbox -ResultSize Unlimited | % {Get-InboxRule -Mailbox $_.UserPrincipalName} | Select MailboxOwnerID, Name, Description | Export-Csv allruleresults.csv -NoTypeInformation

Get-Mailbox -ResultSize Unlimited | % {Get-InboxRule -Mailbox $_.UserPrincipalName | ? {($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectsTo -ne $null)} } | Select MailBoxOwnerID, Name, ForwardTo, ForwardAsAttachmentTo, RedirectTo | Export-Csv allrulesenabled.csv -NoTypeInformation	
### Check for email forwarding for one email address
Get-Mailbox [EmailAddress] | fl ForwardingSMTPAddress,DeliverToMailboxandForward
Get-Mailbox | where {$_.ForwardingAddress -ne $null} | Select Name, ForwardingAddress, DeliverToMailboxAndForward
### Find all email forwarding in the domain
Get-Mailbox -ResultSize Unlimited | Select Name, Alias, ServerName, DeliverToMailboxAndForward | where {$_.DeliverToMailboxAndForward -eq "true"} | Export-Csv ExchangeFWDlist.csv -NoTypeInformation
### Remove an email forward
Set-Mailbox -Identity [EmailAddress] -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $null
### Remove all email forwarding on the domain
Get-Mailbox | Where {$_.ForwardingAddress -ne $null} | Set-Mailbox -ForwardingAddress $null -DeliverToMailboxAndForward $false	
### Send results to a CSV file
[command]| Export-Csv c:\path\to\file.csv -NoTypeInformation	

## Office365
### Get MFA status
```powershell
Connect-MsolService
$User = Get-MSolUser -UserPrincipalName user@domain.com
$User.StrongAuthenticationMethods
```

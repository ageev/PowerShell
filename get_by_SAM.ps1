$name = Read-Host 'Input SAM account name'
Get-ADUser -Filter{SamAccountName -like $name} -Properties PasswordLastSet,BadLogonCount,EmailAddress,LastBadPasswordAttempt,LastLogonDate,LockedOut, BadPwdCount

Write-Host -NoNewLine 'Press any key to close...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
$name = Read-Host 'Input the username'
Get-ADUser -Filter{displayName -like $name} -Properties PasswordLastSet,BadLogonCount,EmailAddress,LastBadPasswordAttempt,LastLogonDate,LockedOut, BadPwdCount

Write-Host -NoNewLine 'Press any key to close...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
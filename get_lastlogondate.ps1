Import-Module ActiveDirectory

#$PropertyName = "PasswordLastSet"
$PropertyName = "LastLogonDate"
$Username = "Grefen, Hans"

function Msg ($Txt="") { 
    Write-Host "$([DateTime]::Now) $Txt" 
}

$List = @() #Define Array 
(Get-ADDomain).ReplicaDirectoryServers | Sort | % { 
    $DC = $_ 
#    Msg "Reading $DC" 
    Get-ADUser -Server $_ -Filter "displayname -like '$Username'" -Properties $PropertyName | Select samaccountname,$PropertyName,@{n='DC';e={$DC}} 
} 

Write-Host -NoNewLine 'Press any key to close...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
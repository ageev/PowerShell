#Using WUA to Scan for Updates Offline with PowerShell 
#VBS version: https://docs.microsoft.com/en-us/previous-versions/windows/desktop/aa387290(v=vs.85) 

# download  http://go.microsoft.com/fwlink/p/?LinkID=74689
# copy to c:\temp\

$UpdateSession = New-Object -ComObject Microsoft.Update.Session 
$UpdateServiceManager  = New-Object -ComObject Microsoft.Update.ServiceManager 
$UpdateService = $UpdateServiceManager.AddScanPackageService("Offline Sync Service", "c:\temp\wsusscn2.cab", 1) 
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()  
 
Write-Output "Searching for updates... `r`n" 
 
$UpdateSearcher.ServerSelection = 3 #ssOthers 
 
$UpdateSearcher.ServiceID = $UpdateService.ServiceID 
 
$SearchResult = $UpdateSearcher.Search("IsInstalled=0 and CategoryIDs contains '0FA1201D-4330-4FA8-8AE9-B877473B6441'") # or "IsInstalled=0 and IsInstalled=1" to also list the installed updates as MBSA did 
 
$Updates = $SearchResult.Updates 
 
if($Updates.Count -eq 0){ 
    Write-Output "There are no applicable updates." 
    return $null 
} 
 
Write-Output "List of applicable items on the machine when using wssuscan.cab: `r`n" 
 
$i = 0 
foreach($Update in $Updates){  
    Write-Output "$($i)> $($Update.Title)" 
    $i++ 
}
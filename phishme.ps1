Write-Output "================= PhishMe Search Script v0.1 ===================="
Write-Output " (c) Artyom Ageyev"
Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null 
$olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type]  
$outlook = new-object -comobject outlook.application 
$namespace = $outlook.GetNameSpace("MAPI") 
$folder = $namespace.Folders("phishreporter@domain.com").Folders("Inbox")
$date = (Get-date).AddHours(-24)
Write-Output "$("Working with emails from") $date"
$search_string = Read-Host "Enter the search string"
$mails = $folder.items | where-object { $_.ReceivedTime -gt $date}  
# $mails = $folder.items | where-object { $_.ReceivedTime -gt [DateTime]::ParseExact($date, 'd/M/yyyy HH:mm:ss',[CultureInfo]::InvariantCulture)} 

$outputdir = "C:\Temp\phishme\"

foreach($mail in $mails){

$tag = ($mail.HTMLBody) -split "`n" | sls $search_string

if ($tag) 
    {
    $filename = $mail.attachments(1).FileName
    Write-Output "$("[INFO] Saving mail ") $filename)"
    $mail.attachments(1).saveasfile($outputdir + $filename)
    }
}

Write-Output "$("[INFO] All mails were saved in ") $outputdir"

Write-Host -NoNewLine 'Press any key to close...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

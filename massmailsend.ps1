Function Get-FileName($initialDirectory, $Title, $Filter)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = $Title
    $OpenFileDialog.filter = $Filter
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$filePath = Get-FileName $env:HOMEDRIVE "Open mail recipient list in CSV format" "CSV (*.csv)| *.csv|TXT (*.txt)| *.txt"
$messagepath = Get-FileName $env:HOMEDRIVE "Open message body in HTML format" "HTM (*.htm)| *.htm|HTML (*.html)| *.html" 
$message = Get-Content $messagepath | Out-String

$mails = Import-Csv -Path $filePath -Header to

ForEach($m in $mails)
{
    $Outlook = New-Object -ComObject Outlook.Application
    $Mail = $Outlook.CreateItem(0)
    $Mail.To = $m.To
    $Mail.Subject = "New letter"
    $Mail.HTMLBody = $message
    $Mail.Send()
    #$inspector = $mail.GetInspector    #use inspector to see message content without sending it
    #$inspector.Display()
}
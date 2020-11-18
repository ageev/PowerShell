# https://doc.nexthink.com/Documentation/Nexthink/V6.24/UserManual/Writingscriptsforremoteactions

Add-Type -Path $env:NEXTHINK\RemoteActions\nxtremoteactions.dll

$dns_data = Resolve-DnsName -Name debug.opendns.com -Type TXT -DnsOnly
$seatch_string = "user id"
$is_found = $FALSE
$string_value = "not found"

foreach ($str in $dns_data.Strings)
{
  if ($str -match $seatch_string)
  {
    $is_found = $TRUE
    $string_value = $str
  }
}

[Nxt]::WriteOutputString("Cisco Umbrella User ID value", $string_value)
[Nxt]::WriteOutputBool("Cisco Umbrella User ID is found", $is_found)

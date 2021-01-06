$monitor = Get-WmiObject -ns root/wmi -class wmiMonitorBrightNessMethods
$monitor.WmiSetBrightness(0,100)
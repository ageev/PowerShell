Add-Type @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static double IdleSeconds {
            get {
                return IdleTime.TotalSeconds;
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
"@

$checkIntervalInSeconds = 2
$preventIdleLimitInSeconds = 10

$monitor = Get-WmiObject -ns root/wmi -class wmiMonitorBrightNessMethods
$flag = $false

while($True) {
    # lower brightness
    if (([PInvoke.Win32.UserInput]::IdleSeconds -ge $preventIdleLimitInSeconds)) {
        $monitor.WmiSetBrightness(0,0)
        $flag = $true
    }

    # increase brightness
    if (([PInvoke.Win32.UserInput]::IdleSeconds -le $preventIdleLimitInSeconds) -And $flag) {
        $monitor.WmiSetBrightness(0,100)
        $flag = $false
    }

    Start-Sleep -Seconds $checkIntervalInSeconds
}

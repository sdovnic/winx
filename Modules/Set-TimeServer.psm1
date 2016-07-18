function Set-TimeServer {
    Param ([Parameter(Mandatory=$true)] [ValidateSet("Default", "Alternative", "Current", "Status")] [String] $Action)
    Process {
        if ($Action.Contains("Alternative")) {
            $Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"
            Set-ItemProperty -Path $Path -Name "0" -Value "0.de.pool.ntp.org"
            Set-ItemProperty -Path $Path -Name "1" -Value "1.de.pool.ntp.org"
            Set-ItemProperty -Path $Path -Name "2" -Value "2.de.pool.ntp.org"
            Set-ItemProperty -Path $Path -Name "3" -Value "3.de.pool.ntp.org"
            Set-ItemProperty -Path $Path -Name "(Default)" -Value "0"
            $Path = "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters"
            Set-ItemProperty -Path $Path -Name "NtpServer" -Value "0.de.pool.ntp.org"
            Restart-Service -Name W32Time
            & 'w32tm' '/resync'
        } elseif ($Action.Contains("Status")) {
            $Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"
            Get-Item -Path $Path | Format-Table -AutoSize
            $Path = "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters"
            Get-Item -Path $Path | Format-Table
            Get-Service -Name W32Time | Format-Table -AutoSize
            & 'w32tm' '/query', '/status'
        } elseif ($Action.Contains("Default")) {
            $Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"
            Set-ItemProperty -Path $Path -Name "1" -Value "time.windows.com"
            Set-ItemProperty -Path $Path -Name "2" -Value "time.nist.gov"
            Set-ItemProperty -Path $Path -Name "3" -Value "time-nw.nist.gov"
            Set-ItemProperty -Path $Path -Name "4" -Value "time-a.nist.gov"
            Set-ItemProperty -Path $Path -Name "4" -Value "time-b.nist.gov"
            Set-ItemProperty -Path $Path -Name "(Default)" -Value "1"
            $Path = "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters"
            Set-ItemProperty -Path $Path -Name "NtpServer" -Value "time.windows.com"
            Restart-Service -Name W32Time
            & 'w32tm' '/resync'
        } elseif ($Action.Contains("Current")) {
            if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters" -Name "NtpServer" | Where-Object {$_.NtpServer -eq "0.de.pool.ntp.org"}) {
                return "Alternative"
            } else {
                return "Default"
            }
        }
    }
}
function Set-Application {
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Remove", "Install")] [string] $Action,
        [parameter(Mandatory=$true)] [string] $Application,
        [parameter(Mandatory=$true)] [string] $User = $env:USERNAME
    )
    process {
        if ($Action.Contains("Remove")) {
            If (Get-AppxPackage -Name $Application) {
                Get-AppxPackage -Name "$Application" | Remove-AppxPackage
            } else {
                Write-Debug -Message "$Application is not present."
            }
        } elseif ($Action.Contains("Install")) {
            if (Get-AppxPackage -AllUsers -Name "$Application") {
                Get-AppxPackage -AllUsers -Name "$Application" | Foreach-Object { $_.Name; Add-AppxPackage -Path “$($_.InstallLocation)\AppXManifest.xml” -Register -DisableDevelopmentMode -ErrorAction SilentlyContinue; }
            } else {
                Write-Debug -Message "$Application could not be installed. Please use the Microsoft Store."
            }
        }
    }
}

function Set-ApplicationFirewallGroup {
    param(
        [parameter(Mandatory=$true)] [ValidateSet("False", "True")] [string] $Enabled,
        [parameter(Mandatory=$true)] [string] $Group
    )
    process {
        if (Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue) {
            if ($Enabled.Contains("False")) {
                Write-Verbose -Message "Disabling Group: $Group"
                Set-NetFirewallRule -Group $Group -Enabled False
            } elseif ($Enabled.Contains("True")) {
                Write-Verbose -Message "Enabling Group: $Group"
                Set-NetFirewallRule -Group $Group -Enabled True
            }
        } else {
            Write-Debug -Message "Group: $Group is not present."
        }
    }
}

function Set-HomeGroup {
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Disable", "Enable", "Status")] [string] $Action
    )
    process {
        if ($Action.Contains("Disable")) {
            Set-Service -Name HomeGroupListener -StartupType Disabled
            Set-Service -Name HomeGroupProvider -StartupType Disabled
            $Restart = $true
        } elseif ($Action.Contains("Enable")) {
            Set-Service -Name HomeGroupListener -StartupType Automatic -Status Running
            Set-Service -Name HomeGroupProvider -StartupType Automatic -Status Running
        } elseif ($Action.Contains("Status")) {
            Get-Service -Name HomeGroupListener
            Get-Service -Name HomeGroupProvider
        }
    }
}

function Set-Cortana {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore", "Status")] [string] $Action
    )
    process {
        $Path = "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowCortana" -Value "0" -Force
            Set-ItemProperty -Path $Path -Name "DisableWebSearch" -Value "1" -Force
            Set-ItemProperty -Path $Path -Name "AllowSearchToUseLocation" -Value "0" -Force
            Set-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb" -Value "0" -Force
        } elseif ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowCortana"
            Remove-ItemProperty -Path $Path -Name "DisableWebSearch"
            Remove-ItemProperty -Path $Path -Name "AllowSearchToUseLocation"
            Remove-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb"
        } elseif ($Action.Contains("Status")) {
            if (Get-ItemProperty -Path $Path -Name "DisableWebSearch" -ErrorAction SilentlyContinue) {
                return $false
            } else {
                return $true
            }
        }
    }
}

function Set-OneDrive {
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Install", "Uninstall", "Status")] [string] $Action
    )
    process {
        [string] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
        if ($Architecture -match "64-Bit") {
            $Path = "$env:SystemRoot\SysWOW64"
        } else {
            $Path = "$env:SystemRoot\System32"
        }
        $Path = Join-Path -Path $Path -ChildPath "OneDriveSetup.exe"
        if ($Action.Contains("Status")) {
            $RemoveOneDrive = $false
            [array] $Folders = @(
                "$env:LOCALAPPDATA\Microsoft\OneDrive",
                "$env:ProgramData\Microsoft OneDrive",
                "$env:USERPROFILE\OneDrive",
                "$env:SystemDrive\OneDriveTemp"
            )
            foreach ($Folder in $Folders) {
                if (Test-Path -Path $Folder) {
                    $RemoveOneDrive = $true
                }
            }
            if ($RemoveOneDrive) {
                return $RemoveOneDrive
            }
        } elseif ($Action.Contains("Uninstall")) {
            Write-Verbose -Message "Invoking Uninstall from OneDrive"
            Start-Process -FilePath $Path -ArgumentList "/uninstall" -Wait
            [array] $Folders = @(
                "$env:LOCALAPPDATA\Microsoft\OneDrive",
                "$env:ProgramData\Microsoft OneDrive",
                "$env:USERPROFILE\OneDrive",
                "$env:SystemDrive\OneDriveTemp"
            )
            foreach ($Folder in $Folders) {
                if (Test-Path -Path $Folder) {
                    Write-Verbose -Message "Removing $Folder"
                    Remove-Item -Path $Folder -Recurse -Force
                }
            }
            New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
            $Path = "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
            $Property = Get-ItemProperty -Path $Path
            if (Test-Path -Path $Path) {
                if ($Property.{System.IsPinnedToNameSpaceTree} -eq "1") {
                    Write-Verbose -Message "Removing OneDrive from Explorer"
                    Set-ItemProperty -Path $Path -Name "System.IsPinnedToNameSpaceTree" -Value "0"
                }
            }
            $Path = "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
            $Property = Get-ItemProperty -Path $Path
            if (Test-Path -Path $Path) {
                if ($Property.{System.IsPinnedToNameSpaceTree} -eq "1") {
                    Write-Verbose -Message "Removing OneDrive from Explorer"
                    Set-ItemProperty -Path $Path -Name "System.IsPinnedToNameSpaceTree" -Value "0"
                }
            }
            Remove-PSDrive -Name "HKCR"
        } elseif ($Action.Contains("Install")) {
            Start-Process -FilePath $Path -Wait
        }
    }
}

function Set-Telemetry {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore", "Status")] [string] $Action
    )
    process {
        $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowTelemetry" -Value "0"
        } elseif ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowTelemetry"
        } elseif ($Action.Contains("Status")) {
            if (Get-ItemProperty -Path $Path -Name "AllowTelemetry" -ErrorAction SilentlyContinue) {
                return $false
            } else {
                return $true
            }
        }
    }
}

function Set-TimeServer {
    param([parameter(Mandatory=$true)] [ValidateSet("Default", "Alternative", "Current", "Status")] [string] $Action)
    process {
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

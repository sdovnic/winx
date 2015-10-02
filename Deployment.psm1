function Set-Application {
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Remove", "Install")] [string] $Action,
        [parameter(Mandatory=$true)] [string] $Application
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
        [parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore")] [string] $Action
    )
    process {
        $Path = "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowCortana" -Value "0"
            Set-ItemProperty -Path $Path -Name "DisableWebSearch" -Value "1"
            Set-ItemProperty -Path $Path -Name "AllowSearchToUseLocation" -Value "0"
            Set-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb" -Value "0"
        }
        if ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowCortana"
            Remove-ItemProperty -Path $Path -Name "DisableWebSearch"
            Remove-ItemProperty -Path $Path -Name "AllowSearchToUseLocation"
            Remove-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb"
        }
    }
}

function Set-Flash {
    <#
        .SYNOPSIS
            Removes or Restores Flash from your Windows 10 Installation.

        .DESCRIPTION
            Set-Flash removes Flash from your Windows 10 Installation and creates a Backup from the removed Files.
            If there is already a Backup Folder it will create an Archive.
            There can occur Problems with Windows Update when you have removed the Files,
            in this case you should restore your Files before updating.

        .PARAMETER Action
            Specifies the Action you want to process. You can choose between Delete and Restore.

        .PARAMETER Dryrun
            Do not delete Files, just pretend.

        .PARAMETER Userdata
            Delete Flash Player Userdata $env:APPDATA\Adobe\Flash Player and $env:APPDATA\Macromedia\Flash Player

        .EXAMPLE
            Set-Flash -Action Delete -Userdata
            This example will remove the Flash Files and Flash Userdata like Flash Cookies and Cache.

        .EXAMPLE
            Set-Flash -Action Restore
            This example will restore the Flash Files.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Delete", "Restore")] [string] $Action,
        [parameter(Mandatory=$false)] [switch] $Dryrun,
        [parameter(Mandatory=$false)] [switch] $Userdata
    )
    process {
        [string] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
        if (-not $PSScriptRoot) { $true; $PSScriptRoot = $psISE.CurrentPowerShellTab.Prompt; }
        [string] $Backup = "Flash-Backup"
        if ($Action.Contains("Delete")) {
            if (Test-Path -Path $Backup) {
                [String] $BackupCopy = Join-Path -Path $PSScriptRoot -ChildPath "$Backup-$((Get-Date).ToString('yyyy-MM-dd-HH-mm-ss'))"
                [String] $BackupArchive = "$BackupCopy.zip"
                Rename-Item -Path $Backup -NewName $BackupCopy
                Add-Type -AssemblyName "System.IO.Compression.Filesystem"
                [IO.Compression.ZipFile]::CreateFromDirectory($BackupCopy, $BackupArchive)
                Remove-Item -Path $BackupCopy -Recurse
            }
            if ($Architecture -match "64-Bit") {
                if (-not (Test-Path -Path $Backup\SysWOW64)) {
                    New-Item -Path $Backup\SysWOW64 -Type Directory
                }
                if (-not (Test-Path -Path $Backup\System32)) {
                    New-Item -Path $Backup\System32 -Type Directory
                }
                if (Test-Path -Path $env:windir\SysWOW64\Macromed) {
                    if (-not $Dryrun.IsPresent) {
                        Move-Item -Path $env:windir\SysWOW64\Macromed -Destination $Backup\SysWOW64\ -Force
                        Move-Item -Path $env:windir\SysWOW64\FlashPlayer* -Destination $Backup\SysWOW64\ -Force
                    } else {
                        Copy-Item -Path $env:windir\SysWOW64\Macromed -Destination $Backup\SysWOW64\ -Recurse
                        Copy-Item -Path $env:windir\SysWOW64\FlashPlayer* -Destination $Backup\SysWOW64\ -Recurse
                    }
                }
                If (Test-Path -Path $env:windir\System32\Macromed) {
                    if (-not $Dryrun.IsPresent) {
                        Move-Item -Path $env:windir\System32\Macromed -Destination $Backup\System32\ -Force
                    } else {
                        Copy-Item -Path $env:windir\System32\Macromed -Destination $Backup\System32\ -Recurse
                    }
                }
            } else {
                Write-Debug -Message "Todo: x86"
            }
            if ($Userdata.IsPresent) {
                Remove-Item -Path "$env:APPDATA\Adobe\Flash Player" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "$env:APPDATA\Macromedia\Flash Player" -Recurse -Force -ErrorAction SilentlyContinue
            }
        } elseif ($Action.Contains("Restore")) {
            if (Test-Path -Path $Backup) {
                if ($Architecture -match "64-Bit") {
                    Copy-Item -Path $Backup\SysWOW64\Macromed -Destination $env:windir\SysWOW64 -Recurse -Force
                    Copy-Item -Path $Backup\SysWOW64\FlashPlayer* -Destination $env:windir\SysWOW64 -Force
                    Copy-Item -Path $Backup\System32\Macromed -Destination $env:windir\System32 -Recurse -Force
                } else {
                    Write-Debug -Message "Todo: x86"
                }
            }
        }
    }
}

function Set-OneDrive {
    param([parameter(Mandatory=$true)] [ValidateSet("Install", "Uninstall")] [string] $Action)
    process {
        [string] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
        if ($Architecture -match "64-Bit") {
            $Path = "$env:SystemRoot\SysWOW64"
        } else {
            $Path = "$env:SystemRoot\System32"
        }
        $Path = Join-Path -Path $Path -ChildPath "OneDriveSetup.exe"
        if ($Action.Contains("Uninstall")) {
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
                    Remove-Item -Path $Folder -Recurse
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
            $Restart = $true
        } elseif ($Action.Contains("Install")) {
            Start-Process -FilePath $Path -Wait
        }
    }
}

function Set-Telemetry {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore")] [string] $Action
    )
    process {
        $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowTelemetry" -Value "0"
        }
        if ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowTelemetry"
        }
    }
}

function Set-TimeServer {
    param([parameter(Mandatory=$true)] [ValidateSet("Default", "Alternative", "Status")] [string] $Action)
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
        }
    }
}

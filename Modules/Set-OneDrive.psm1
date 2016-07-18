function Set-OneDrive {
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Install", "Uninstall", "Status")] [String] $Action
    )
    Process {
        [String] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
        if ($Architecture -match "64-Bit") {
            $Path = "$env:SystemRoot\SysWOW64"
        } else {
            $Path = "$env:SystemRoot\System32"
        }
        $Path = Join-Path -Path $Path -ChildPath "OneDriveSetup.exe"
        if ($Action.Contains("Status")) {
            $RemoveOneDrive = $false
            [Array] $Folders = @(
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
            [Array] $Folders = @(
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
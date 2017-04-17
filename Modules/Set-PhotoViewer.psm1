function Set-PhotoViewer {
    <#
        .SYNOPSIS
            Activates or restores PhotoViewer from your Windows 10 Installation.

        .DESCRIPTION
            Set-PhotoViewer activates or restores the Windows PhotoViewer from your Windows 10 Installation.

        .PARAMETER Action
            Specifies the Action you want to process. You can choose between Activate and Default.

        .EXAMPLE
            Set-PhotoViewer -Action Activate
            This example will activate the PhotoViewer.

        .EXAMPLE
            Set-PhotoViewer -Action Default
            This example will restore the default PhotoViewer Settings.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Activate", "Default")] [String] $Action
    )
    Begin {
        if (-not (Get-PSDrive -Name HKCR -ErrorAction SilentlyContinue)) {
            New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
        }
    }
    Process {
        if ($Action.Contains("Activate")) {
            if (Get-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print -Name NeverDefault -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print -Name NeverDefault -Force
            }
            New-Item -Path HKCR:\Applications\photoviewer.dll\shell\open\command -ItemType Directory -Force
            New-Item -Path HKCR:\Applications\photoviewer.dll\shell\open\DropTarget -ItemType Directory -Force
            New-Item -Path HKCR:\Applications\photoviewer.dll\shell\print\command -ItemType Directory -Force
            New-Item -Path HKCR:\Applications\photoviewer.dll\shell\print\DropTarget -ItemType Directory -Force
            New-Item -Path HKCR:\Applications\photoviewer.dll\shell\open -Name MuiVerb -Value "@photoviewer.dll,-3043" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\open\command -Name "(default)" -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\open\DropTarget -Name Clsid -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print\command -Name "(default)" -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print\DropTarget -Name Clsid -Value "{60fd46de-f830-4894-a628-6fa81bc0190d}" -Force
        }
        if ($Action.Contains("Default")) {
            if (Get-Item -Path HKCR:\Applications\photoviewer.dll\shell\open -ErrorAction SilentlyContinue) {
                Remove-Item -Path HKCR:\Applications\photoviewer.dll\shell\open -Recurse -Force
            }
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print -Name NeverDefault -Value "" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print\command -Name "(default)" -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1" -Force
            Set-ItemProperty -Path HKCR:\Applications\photoviewer.dll\shell\print\DropTarget -Name Clsid -Value "{60fd46de-f830-4894-a628-6fa81bc0190d}" -Force
        }
    }
    End {
        if (Get-PSDrive -Name HKCR -ErrorAction SilentlyContinue) {
            Remove-PSDrive -Name HKCR
        }
    }
}
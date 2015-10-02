if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WindowStyle Hidden -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
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
Remove-Variable -Name Wpf*
[xml] $Xaml = @"
<Window x:Class="WpfApplication3.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication3"
        mc:Ignorable="d"
        Title="MainWindow">
    <Grid>
        <Grid HorizontalAlignment="Left" Margin="10,10,10,10" VerticalAlignment="Top">
            <Label x:Name="label0" Content="Label" HorizontalAlignment="Left" VerticalAlignment="Top"/>
        </Grid>
        <Grid Margin="10" HorizontalAlignment="Left" VerticalAlignment="Bottom">
            <CheckBox x:Name="checkbox0" HorizontalAlignment="Left" VerticalAlignment="Center"/><Label Content="Label" x:Name="label1" HorizontalAlignment="Left" VerticalAlignment="Bottom" Margin="15,0,0,0"/>
        </Grid>
        <Grid Margin="10" HorizontalAlignment="Right" VerticalAlignment="Bottom">
            <Button x:Name="button0" Content="Button" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="75"/>
            <Button x:Name="button1" Content="Button" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="75" Margin="-80,0,80,0"/>
            <Button x:Name="button2" Content="Button" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="75" Margin="-160,0,160,0"/>
        </Grid>
    </Grid>
</Window>
"@ -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,System.Windows.Forms
$Form = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $Xaml))
$Xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name "Wpf.$($_.Name)" -Value $Form.FindName($_.Name) }
Set-Location $PSScriptRoot
${Wpf.button0}.Content = "Schließen"
${Wpf.button0}.add_Click({
    $Form.Close()
})
${Wpf.button1}.add_Click({
    if (Test-Path -Path $env:windir\SysWOW64\Macromed) {
        if (${Wpf.checkbox0}.IsChecked) {
            Set-Flash -Action Delete -Userdata
        } else {
            Set-Flash -Action Delete
        }
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Result = [System.Windows.Forms.MessageBox]::Show(
            "Flash wurde entfernt.",
            "Flash", 0, [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Result = [System.Windows.Forms.MessageBox]::Show(
            "Flash wurde bereits entfernt!",
            "Flash", 0, [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
})
${Wpf.button2}.add_Click({
    $Path = "Flash-Backup"
    if (Test-Path -Path $Path) {
        Set-Flash -Action Restore -Verbose
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Result = [System.Windows.Forms.MessageBox]::Show(
            "Flash wurde wiederhergestellt.",
            "Flash", 0, [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } else {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Result = [System.Windows.Forms.MessageBox]::Show(
            "Kein Backup von Flash gefunden! Bitte stellen Sie das Backup aus einem Archiv in den Ordner `"$Path`" wieder her.",
            "Flash", 0, [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
})
${Wpf.button1}.Content = "Entfernen"
${Wpf.button2}.Content = "Wiederherstellen"
${Wpf.button2}.Width = 120
${Wpf.label0}.Content = "Achtung! Das entfernen von Flash aus Ihrem System kann Probleme mit Windows Update verursachen.`n`nSollten Probleme auftreten stellen Sie Flash aus dem Backup wieder her."
${Wpf.label0}.Height = 180
${Wpf.label1}.Content = "Flash Benutzerdaten mitentfernen."
${Wpf.checkbox0}.IsChecked = $true
$Form.Title = "Flash"
$Form.Height = 190
$Form.MinHeight = 190
$Form.MaxHeight = 190
$Form.Width = 600
$Form.MinWidth = 600
$Form.MaxWidth = 600
$Form.ResizeMode = "NoResize"
$Form.ShowDialog() | Out-Null
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WindowStyle Hidden -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
}

Import-LocalizedData -BaseDirectory $PSScriptRoot\Locales -BindingVariable Messages

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-PhotoViewer)

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
Set-Location -Path $PSScriptRoot
${Wpf.button0}.Content = $messages."Close"
${Wpf.button0}.add_Click({
    $Form.Close()
})
${Wpf.button1}.add_Click({
    Set-PhotoViewer -Action Activate
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Result = [System.Windows.Forms.MessageBox]::Show(
        "PhotoViewer Verwendung aktiviert.",
        "PhotoViewer", 0, [System.Windows.Forms.MessageBoxIcon]::Information
    )
    $Form.Close()
})
${Wpf.button2}.add_Click({
    Set-PhotoViewer -Action Default
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Result = [System.Windows.Forms.MessageBox]::Show(
        "PhotoViewer Einstellungen auf den Werkszustand gesetzt.",
        "PhotoViewer", 0, [System.Windows.Forms.MessageBoxIcon]::Information
    )
    $Form.Close()
})
${Wpf.button1}.Content = $messages."Activate"
${Wpf.button2}.Content = $messages."Restore"
${Wpf.button2}.Width = 120
${Wpf.label0}.Content = "Aktiviert das Fotoanzeigeprogramm PhotoViewer unter Windows 10.`n`nVerwenden Sie Wiederherstellen um auf den Werkszustand zur$([char]0x00FC)ckzusetzten."
${Wpf.label0}.Height = 180
$Form.Title = "PhotoViewer"
$Form.Height = 190
$Form.MinHeight = 190
$Form.MaxHeight = 190
$Form.Width = 450
$Form.MinWidth = 450
$Form.MaxWidth = 450
$Form.ResizeMode = "NoResize"
$Form.ShowDialog() | Out-Null

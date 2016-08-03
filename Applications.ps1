if ($PSVersionTable.PSVersion.Major -lt 3) {
    [String] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
   [String] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath $env:USERNAME"
    return
}

Set-Location -Path $PSScriptRoot

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-Application)

Set-PSDebug -Strict

Set-StrictMode -Version "3.0"

Import-LocalizedData -BindingVariable messages -ErrorAction SilentlyContinue

# You can remove or apply your custom choices to this arrays.

# Windows Applications

[Array] $Applications = @(
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.3DBuilder",
    "Microsoft.BingSports",
    "Microsoft.WindowsMaps",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.WindowsPhone",
    "Microsoft.WindowsDVDPlayer",
    "Microsoft.BingWeather",
    "Microsoft.ZuneVideo",
    "Microsoft.ZuneMusic",
    "Microsoft.Office.OneNote",
    "Microsoft.Windows.Photos",
    "Microsoft.XboxApp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.People",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "microsoft.windowscommunicationsapps",
    "Microsoft.CommsPhone",
    "Microsoft.Office.Sway",
    "Microsoft.SkypeApp",
    "Microsoft.BingFinance",
    "Microsoft.Getstarted",
    "Microsoft.BingNews",
    "Microsoft.Messaging",
    "king.com.CandyCrushSodaSaga",
    "9E2F88E3.Twitter",
    "Microsoft.OneConnect",
    "Microsoft.ConnectivityStore",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.Advertising.Xaml"
)

# Script starts here

$Restart = $false

$messages."The default answer is yes."

foreach ($Application in $Applications) {
    if (Get-AppxPackage -Name $Application -User $env:USERNAME -ErrorAction SilentlyContinue) {
        $question = Read-Host -Prompt ($messages."Remove Application: {0}? [Y/n]" -f $Application)
        if (-not ($question.ToLower() -eq "n")) {
            Set-Application -Application $Application -Action Remove
        }
        Remove-Variable -Name question
    } else {
        $messages."You already removed the following Application: {0}" -f $Application
    }
}

if ($Restart) {
    $messages."You may need to restart your computer and run the script again."
}

Read-Host -Prompt $messages."You are done, press enter to exit"

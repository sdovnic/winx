if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

Set-Location -Path $PSScriptRoot

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath "Deployment.psm1")

Set-PSDebug -Strict

Set-StrictMode -Version "3.0"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
}

# You can remove or apply your custom choices to this arrays.

# Windows Applications

[array] $Applications = @(
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
    "9E2F88E3.Twitter"
)

# Windows Optional Features

[array] $Features = @(
    "Internet-Explorer-Optional-amd64",
    "MediaPlayback",
    "WindowsMediaPlayer",
    "WorkFolders-Client"
)

# Windows Firewall Rule Groups

[array] $Groups = @(
    "windows_ie_ac_001",
    "@{Microsoft.AAD.BrokerPlugin_1000.10240.16384.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.AAD.BrokerPlugin/resources/PackageDisplayName}",
    "@{Microsoft.AAD.BrokerPlugin_1000.10586.0.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.AAD.BrokerPlugin/resources/PackageDisplayName}",
    "@{Microsoft.Windows.CloudExperienceHost_10.0.10240.16384_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.CloudExperienceHost/resources/appDescription}",
    "@{Microsoft.Windows.CloudExperienceHost_10.0.10586.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.CloudExperienceHost/resources/appDescription}",
    "Xbox",
    "OneNote",
    "@{Microsoft.WindowsStore_2015.8.12.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.WindowsStore/Resources/StoreTitle}",
    "@{Microsoft.WindowsStore_2015.10.13.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.WindowsStore/Resources/StoreTitle}",
    "@{Microsoft.Appconnector_1.3.3.0_neutral__8wekyb3d8bbwe?ms-resource://Microsoft.Appconnector/Resources/ConnectorStubTitle}",
    "@{Microsoft.AccountsControl_10.0.10240.16384_neutral__cw5n1h2txyewy?ms-resource://Microsoft.AccountsControl/Resources/DisplayName}",
    "@{Microsoft.AccountsControl_10.0.10586.0_neutral__cw5n1h2txyewy?ms-resource://Microsoft.AccountsControl/Resources/DisplayName}",
    "@{Microsoft.ZuneVideo_3.6.12391.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.ZuneVideo/resources/IDS_MANIFEST_VIDEO_APP_NAME}",
    "@{Microsoft.ZuneMusic_3.6.12391.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.ZuneMusic/resources/IDS_MANIFEST_MUSIC_APP_NAME}",
    "@{Microsoft.Windows.ParentalControls_1000.10240.16384.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.ParentalControls/resources/DisplayName}",
    "@{Microsoft.Windows.ParentalControls_1000.10586.0.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.ParentalControls/resources/DisplayName}",
    "@{Microsoft.Windows.Cortana_1.4.8.176_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.Cortana/resources/DisplayName}",
    "@{Microsoft.Windows.Cortana_1.6.1.52_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.Cortana/resources/DisplayName}",
    "@{Microsoft.WindowsFeedback_10.0.10240.16393_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.WindowsFeedback/FeedbackApp.Resources/AppName/Text}",
    "@{Microsoft.WindowsFeedback_10.0.10586.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.WindowsFeedback/FeedbackApp.Resources/AppName/Text}",
    "@{Microsoft.Windows.ContentDeliveryManager_10.0.10240.16384_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.ContentDeliveryManager/resources/AppDisplayName}",
    "@{Microsoft.Windows.ContentDeliveryManager_10.0.10586.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.Windows.ContentDeliveryManager/resources/AppDisplayName}",
    "@{Microsoft.Windows.Photos_15.803.16240.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.Windows.Photos/Resources/AppStoreName}",
    "@{Microsoft.WindowsDVDPlayer_3.6.11761.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.WindowsDVDPlayer/resources/IDS_DVDPLAYER_APP_NAME}",
    "@{Microsoft.WindowsStore_2015.8.3.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.WindowsStore/Resources/StoreTitle}",
    "@{Microsoft.WindowsMaps_4.1507.50813.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.WindowsMaps/Resources/AppStoreName}",
    "@{Microsoft.People_1.10241.0.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.People/resources/AppStoreName}",
    "@{Microsoft.MicrosoftEdge_20.10240.16384.0_neutral__8wekyb3d8bbwe?ms-resource://Microsoft.MicrosoftEdge/Resources/AppName}",
    "@{Microsoft.MicrosoftEdge_25.10586.0.0_neutral__8wekyb3d8bbwe?ms-resource://Microsoft.MicrosoftEdge/Resources/AppName}",
    "@{microsoft.windowscommunicationsapps_17.6118.42001.0_x64__8wekyb3d8bbwe?ms-resource://microsoft.windowscommunicationsapps/hxcommintl/AppManifest_OutlookDesktop_DisplayName}",
    "@{Microsoft.Getstarted_2.2.7.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.Getstarted/Resources/AppStoreName}",
    "@{Microsoft.BingWeather_4.4.200.0_x86__8wekyb3d8bbwe?ms-resource://Microsoft.BingWeather/Resources/ApplicationTitleWithBranding}",
    "@{Microsoft.BingNews_4.4.200.0_x86__8wekyb3d8bbwe?ms-resource://Microsoft.BingNews/Resources/ApplicationTitleWithBranding}",
    "@{Microsoft.BingFinance_4.4.200.0_x86__8wekyb3d8bbwe?ms-resource://Microsoft.BingFinance/Resources/ApplicationTitleWithBranding}",
    "@{Windows.ContactSupport_10.0.10240.16384_neutral_neutral_cw5n1h2txyewy?ms-resource://Windows.ContactSupport/Resources/appDisplayName}",
    "@{Windows.ContactSupport_10.0.10586.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Windows.ContactSupport/Resources/appDisplayName}",
    "@{Windows.PurchaseDialog_6.2.0.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Windows.PurchaseDialog/resources/DisplayName}",
    "@{Microsoft.XboxIdentityProvider_1000.10240.16384.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.XboxIdentityProvider/Resources/PkgDisplayName}",
    "@{Microsoft.XboxIdentityProvider_1000.10586.0.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.XboxIdentityProvider/Resources/PkgDisplayName}",
    "@{Microsoft.XboxGameCallableUI_1000.10240.16384.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.XboxGameCallableUI/resources/PkgDisplayName}",
    "@{Microsoft.XboxGameCallableUI_1000.10586.0.0_neutral_neutral_cw5n1h2txyewy?ms-resource://Microsoft.XboxGameCallableUI/resources/PkgDisplayName}",
    "@{Microsoft.LockApp_10.0.10240.16384_neutral__cw5n1h2txyewy?ms-resource://Microsoft.LockApp/resources/AppDisplayName}",
    "@{Microsoft.LockApp_10.0.10586.0_neutral__cw5n1h2txyewy?ms-resource://Microsoft.LockApp/resources/AppDisplayName}"
)

# Windows Services

$Services = @(
    "diagnosticshub.standardcollector.service"  # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                 # Diagnostics Tracking Service
    "dmwappushservice"                          # WAP Push Message Routing Service
    #"HomeGroupListener"                        # HomeGroup Listener
    #"HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                     # Geolocation Service
    "MapsBroker"                                # Downloaded Maps Manager
    #"NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    #"RemoteAccess"                             # Routing and Remote Access
    #"RemoteRegistry"                           # Remote Registry
    "SharedAccess"                              # Internet Connection Sharing (ICS)
    "TrkWks"                                    # Distributed Link Tracking Client
    "WbioSrvc"                                  # Windows Biometric Service
    "WlanSvc"                                   # WLAN AutoConfig
    #"WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    #"wscsvc"                                   # Windows Security Center Service
    #"WSearch"                                  # Windows Search
    "XblAuthManager"                            # Xbox Live Auth Manager
    "XblGameSave"                               # Xbox Live Game Save Service
    "XboxNetApiSvc"                             # Xbox Live Networking Service
)

# Script starts here

$Restart = $false

"Default Answer is Yes."

foreach ($Application in $Applications) {
    if (Get-AppxPackage -Name $Application -User $env:USERNAME -ErrorAction SilentlyContinue) {
        $question = Read-Host -Prompt "Remove Application: ${Application}? [Y/n]"
        if (-not ($question.ToLower() -eq "n")) {
            Set-Application -Application $Application -Action Remove
        }
        Remove-Variable -Name question
    }
}

foreach ($Feature in $Features) {
    if (Get-WindowsOptionalFeature -FeatureName $Feature -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Enabled"}) {
        $question = Read-Host -Prompt "Disable Windows Optional Feature: ${Feature}? [Y/n]"
        if (-not ($question.ToLower() -eq "n")) {
            Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature
            $Restart = $true
        }
        Remove-Variable -Name question
    }
}

foreach ($Group in $Groups) {
    if (Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq "True"}) {
        [array] $DisplayName = Get-NetFirewallRule -Group $Group | Select-Object -ExpandProperty DisplayName
        $DisplayName = $DisplayName[0]
        $question = Read-Host -Prompt "Disable Firewall Rule: ${DisplayName}? [Y/n]"
        if (-not ($question.ToLower() -eq "n")) {
            Set-ApplicationFirewallGroup -Group $Group -Enable False
        }
        Remove-Variable -Name question
    }
}

foreach ($Service in $Services) {
    if (-not (Get-Service -Name $Service | Where-Object {$_.StartType -eq "Disabled"})) {
        $DisplayName = $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
        $question = Read-Host -Prompt "Disable Service: ${DisplayName}? [Y/n]"
        if (-not ($question.ToLower() -eq "n")) {
            Get-Service -Name $Service | Set-Service -StartupType Disabled
            Get-Service -Name $Service | Set-Service -Status Stopped -ErrorAction SilentlyContinue
            $Restart = $true
        }
        Remove-Variable -Name question
    }
}

if (-not (Get-Service -Name HomeGroupProvider -ErrorAction SilentlyContinue | Where-Object {$_.StartType -eq "Disabled"})) {
    $question = Read-Host -Prompt "Disable Windows Home Groups? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-HomeGroup -Action Disable
        $Restart = $true
    }
    Remove-Variable -Name question
}

if (Set-OneDrive -Action Status) {
    $question = Read-Host -Prompt "Remove Microsoft OneDrive? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-OneDrive -Action Uninstall
        $Restart = $true
    }
    Remove-Variable -Name question
}

if (Set-Telemetry -Action Status) {
    $question = Read-Host -Prompt "Disable Windows Telemetry? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-Telemetry -Action Disable
        $Restart = $true
    }
    Remove-Variable -Name question
}

#if (Set-Cortana -Action Status) {
#    $question = Read-Host -Prompt "Disable Windows Cortana? [Y/n]"
#    if (-not ($question.ToLower() -eq "n")) {
#        Set-Cortana -Action Disable
#    }
#    Remove-Variable -Name question
#}

if ((Set-TimeServer -Action Current) -eq "Default") {
    $question = Read-Host -Prompt "Set Alternative Network Time Servers? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-TimeServer -Action Alternative
        $Restart = $true
    }
    Remove-Variable -Name question
}

if ($Restart) {
    "You may need to restart your Computer and rerun the script."
}

Read-Host -Prompt "You are done press enter to exit"
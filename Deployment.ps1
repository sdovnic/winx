if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

Set-Location $PSScriptRoot

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath "Deployment.psm1")

Set-PSDebug -Strict

Set-StrictMode -Version "3.0"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
}

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
    #"Microsoft.XboxGameCallableUI",
    #"Microsoft.XboxIdentityProvider",
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
    #"Windows.ContactSupport"
)

"These Applications will be removed:`n"
foreach ($Application in $Applications) {
    $Application
}
$question = Read-Host -Prompt "`nAre you sure? [y/n]"

"`n"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    [int] $Index = 0
    foreach ($Application in $Applications) {
        Write-Progress -Activity "Removing Applications" -Status $Application -PercentComplete ($Index / $Applications.Count * 100)
        Set-Application -Application $Application -Action Remove
    }
}

"`n"

Remove-Variable question

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

"These Firewall Rules will be disabled:`n"
foreach ($Group in $Groups) {
    $(Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName)
}
$question = Read-Host -Prompt "`nAre you sure? [y/n]"

"`n"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    [int] $Index = 0
    foreach ($Group in $Groups) {
        Write-Progress -Activity "Disabling Firewall Rule" -Status $Group -PercentComplete ($Index / $Groups.Count * 100)
        Set-ApplicationFirewallGroup -Group $Group -Enable False
    }
}

"`n"

Remove-Variable question

[array] $Features = @(
    "Internet-Explorer-Optional-amd64",
    "MediaPlayback",
    "WindowsMediaPlayer",
    "WorkFolders-Client"
)

"These Optional Windows Features will be disabled:`n"
foreach ($Feature in $Features) {
    $Feature
}
$question = Read-Host -Prompt "`nAre you sure? [y/n]"

"`n"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    foreach ($Feature in $Features) {
        #if (-not (Get-WindowsOptionalFeature -Online -FeatureName $Feature | Select-Object -Property State) -eq "Disabled") {
            Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature
        #}
    }
}

# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/disable-windows-features.ps1

Remove-Variable question

$question = Read-Host -Prompt "`nDo you like to disable Windows Home Groups? [y/n]"

"`n"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    Set-HomeGroup -Action Disable
}

Remove-Variable question

$question = Read-Host -Prompt "`nDo you like to remove Microsoft OneDrive? [y/n]"

"`n"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    Set-OneDrive -Action Uninstall
}

# Todo: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-onedrive.ps1

"`n"

Remove-Variable question

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

    # Services which cannot be disabled
    #"WdNisSvc"
)

"These Services will be disabled:`n"
foreach ($Service in $Services) {
    $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
}
$question = Read-Host -Prompt "`nAre you sure? [y/n]"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    foreach ($Service in $Services) {
        Get-Service -Name $Service | Set-Service -StartupType Disabled
        Get-Service -Name $Service | Set-Service -Status Stopped -ErrorAction SilentlyContinue
    }
}

# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/disable-services.ps1

"`n"

Remove-Variable question

$question = Read-Host -Prompt "`nDo you like to disable Windows Telemetry? [y/n]"

if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    Set-Telemetry -Action Disable
}

# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/disable-windows-features.ps1

Remove-Variable question

$question = Read-Host -Prompt "`nDo you like to set Alternative Time Servers? [y/n]"
if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    Set-TimeServer -Action Alternative
}

"`n"

Remove-Variable question

$question = Read-Host -Prompt "`nDo you like to disable Cortana? [y/n]"
if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
    Set-Cortana -Action Disable
}

"`n"

Remove-Variable question

# https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/disable-windows-features.ps1

Read-Host "You are done press any enter to exit"

Benutzererfahrung und Telemetrie im verbundenen Modus

# Diagnosenachverfolgungsdienst heisst jetzt Benutzererfahrung und Telemetrie im verbundenen Modus 
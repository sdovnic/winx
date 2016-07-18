if ($PSVersionTable.PSVersion.Major -lt 3) {
    [String] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
    [String] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

Set-Location -Path $PSScriptRoot

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-OneDrive)
Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-TimeServer)
Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-Telemetry)
# Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-Cortana)
Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-HomeGroup)
Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-ApplicationFirewallGroup)

Set-PSDebug -Strict

Set-StrictMode -Version "3.0"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath $env:USERNAME"
    return
}

if ($args.Length -gt 0) {
    $Username = $args[0]
} else {
    $Username = $env:USERNAME
}

Import-LocalizedData -BindingVariable messages -ErrorAction SilentlyContinue

# You can remove or apply your custom choices to this arrays.

# Windows Optional Features

[Array] $Features = @(
    "Internet-Explorer-Optional-amd64",
    "MediaPlayback",
    "WindowsMediaPlayer",
    "WorkFolders-Client"
)

# Windows Firewall Rule Groups

[Array] $Groups = @(
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

$messages."The default answer is yes."

foreach ($Feature in $Features) {
    if (Get-WindowsOptionalFeature -FeatureName $Feature -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Enabled"}) {
        $question = Read-Host -Prompt ($messages."Disable Windows Optional Feature: {0}? [Y/n]" -f $Feature)
        if (-not ($question.ToLower() -eq "n")) {
            Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature
            $Restart = $true
        }
        Remove-Variable -Name question
    } else {
        $messages."You already disabled the following Windows Optional Feature: {0}" -f $Feature
    }
}

foreach ($Group in $Groups) {
    if (Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq "True"}) {
        [Array] $DisplayName = Get-NetFirewallRule -Group $Group | Select-Object -ExpandProperty DisplayName
        $DisplayName = $DisplayName[0]
        $question = Read-Host -Prompt ($messages."Disable Firewall Rule: {0}? [Y/n]" -f $DisplayName)
        if (-not ($question.ToLower() -eq "n")) {
            Set-ApplicationFirewallGroup -Group $Group -Enable False
        }
        Remove-Variable -Name question
    } elseif (Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue | Where-Object {$_.Enabled -eq "False"}) {
        [Array] $DisplayName = Get-NetFirewallRule -Group $Group | Select-Object -ExpandProperty DisplayName
        $DisplayName = $DisplayName[0]
        $messages."You already disabled the following Firewall Rule: {0}" -f $DisplayName
    }
}

foreach ($Service in $Services) {
    if (-not (Get-Service -Name $Service | Where-Object {$_.StartType -eq "Disabled"})) {
        $DisplayName = $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
        $question = Read-Host -Prompt ($messages."Disable Service: {0}? [Y/n]" -f $DisplayName)
        if (-not ($question.ToLower() -eq "n")) {
            Get-Service -Name $Service | Set-Service -StartupType Disabled
            Get-Service -Name $Service | Set-Service -Status Stopped -ErrorAction SilentlyContinue
            $Restart = $true
        }
        Remove-Variable -Name question
    } elseif (Get-Service -Name $Service | Where-Object {$_.StartType -eq "Disabled"}) {
        $DisplayName = $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
        $messages."You already disabled the following Service: {0}" -f $DisplayName
    }
}

if (-not (Get-Service -Name HomeGroupProvider -ErrorAction SilentlyContinue | Where-Object {$_.StartType -eq "Disabled"})) {
    $question = Read-Host -Prompt $messages."Disable Windows Home Groups? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-HomeGroup -Action Disable
        $Restart = $true
    }
    Remove-Variable -Name question
} else {
    $messages."You already disabled Windows Home Groups."
}

if (Set-OneDrive -Action Status) {
    $question = Read-Host -Prompt $messages."Remove Microsoft OneDrive? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-OneDrive -Action Uninstall
        $Restart = $true
    }
    Remove-Variable -Name question
} else {
    $messages."You already removed Microsoft OneDrive."
}

if (Set-Telemetry -Action Status) {
    $question = Read-Host -Prompt $messages."Disable Windows Telemetry? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-Telemetry -Action Disable
        $Restart = $true
    }
    Remove-Variable -Name question
} else {
    $messages."You already disabled Windows Telemetry."
}

# if (Set-Cortana -Action Status) {
#     $question = Read-Host -Prompt "Disable Windows Cortana? [Y/n]"
#     if (-not ($question.ToLower() -eq "n")) {
#         Set-Cortana -Action Disable
#     }
#     Remove-Variable -Name question
# }

if ((Set-TimeServer -Action Current) -eq "Default") {
    $question = Read-Host -Prompt $messages."Set alternative Network Time Servers? [Y/n]"
    if (-not ($question.ToLower() -eq "n")) {
        Set-TimeServer -Action Alternative
        $Restart = $true
    }
    Remove-Variable -Name question
} else {
    $messages."You already set alternative Network Time Servers."
}

if ($Restart) {
    $messages."You may need to restart your computer and run the script again."
}

Read-Host -Prompt $messages."You are done, press enter to exit"

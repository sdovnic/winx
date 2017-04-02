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

Import-LocalizedData -BaseDirectory $PSScriptRoot\Locales -BindingVariable Messages

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Get-Choice)

# You can remove or apply your custom choices to this arrays.

# Applications

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
    "Microsoft.XboxIdentityProvider",
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
    "Microsoft.OneConnect",
    "Microsoft.ConnectivityStore",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.Advertising.Xaml",
    "9E2F88E3.Twitter",
    "king.com.CandyCrushSodaSaga"
)

# Windows Optional Features

[Array] $Features = @(
    "Internet-Explorer-Optional-amd64",
    "MediaPlayback",
    "WindowsMediaPlayer",
    "WorkFolders-Client"
)

# Windows Firewall Rule Groups

[Array] $Groups = @(
    "Xbox",
    "OneNote",
    "DiagTrack",
    "Store Purchase App",
    "windows_ie_ac_001",
    "Microsoft.AAD.BrokerPlugin",
    "Microsoft.Windows.CloudExperienceHost",
    "Microsoft.WindowsStore",
    "Microsoft.Appconnector",
    "Microsoft.AccountsControl",
    "Microsoft.ZuneVideo",
    "Microsoft.ZuneMusic",
    "Microsoft.Windows.ParentalControls",
    "Microsoft.Windows.Cortana",
    "Microsoft.WindowsFeedback",
    "Microsoft.Windows.ContentDeliveryManager",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsDVDPlayer",
    "Microsoft.WindowsStore",
    "Microsoft.WindowsMaps",
    "Microsoft.People",
    "Microsoft.MicrosoftEdge",
    "microsoft.windowscommunicationsapps",
    "Microsoft.Getstarted",
    "Microsoft.BingWeather",
    "Microsoft.BingNews",
    "Microsoft.BingFinance",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.LockApp",
    "Microsoft.ConnectivityStore",
    "Windows.ContactSupport",
    "Windows.PurchaseDialog"
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

# Cortana

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Set-Cortana)

if ((Set-Cortana -Action Status) -eq "True") {
    $DisplayName = "Cortana"
    $Choices = @(
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Disable"),
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
    )
    $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $DisplayName -Message ($Messages."Disable: {0}?" -f $DisplayName)
    switch ($Choice) {
        0 {
            Set-Cortana -Action Disable
        }
    }
} else {
    $DisplayName = "Cortana"
    $Messages."You already disabled {0}." -f $DisplayName
}

# Windows Default Applications

foreach ($Application in $Applications) {
    $Package = Get-AppxPackage -AllUsers -Name $Application
    if ($Package) {
        $InstallState = (Get-AppxPackage -AllUsers -Name $Application | Select-Object -ExpandProperty PackageUserInformation | Select-Object -Property InstallState)
        if ($InstallState -match "Installed") {
            $Choices = @(
                (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Remove Application"),
                (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
            )
            $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $Application -Message ($Messages."Remove Application: {0}?" -f $Application)
            switch ($Choice) {
                0 {
                    $Package | Remove-AppxPackage
                }
            }
        } else {
            $Messages."You already removed the following Application: {0}" -f $Application
        }
    }
}

# Windows Optional Features

foreach ($Feature in $Features) {
    if (Get-WindowsOptionalFeature -FeatureName $Feature -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Enabled"}) {
        $Choices = @(
            (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Disable Windows Optional Feature"),
            (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
        )
        $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $Feature -Message ($Messages."Disable Windows Optional Feature: {0}?" -f $Feature)
        switch ($Choice) {
            0 {
                Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature
            }
        }
    } else {
        $Messages."You already disabled the following Windows Optional Feature: {0}" -f $Feature
    }
}

# Firewall Groups

foreach ($Group in $Groups) {
    foreach ($Rule in Get-NetFirewallRule -Group *${Group}*) {
        if (Get-NetFirewallRule -Name $Rule.Name | Where-Object {$_.Enabled -eq "True"}) {
            $Choices = @(
                (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Disable Firewall Rule"),
                (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
            )
            $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $Rule.DisplayName -Message ($Messages."Disable Firewall Rule: {0}?" -f $Rule.DisplayName)
            switch ($Choice) {
                0 {
                    Set-NetFirewallRule -Name $Rule.Name -Enabled False
                }
            }
        } elseif (Get-NetFirewallRule -Name $Rule.Name | Where-Object {$_.Enabled -eq "False"}) {
            $Messages."You already disabled the following Firewall Rule: {0}" -f $Rule.DisplayName
        }
    }
}

# Services

foreach ($Service in $Services) {
    if (-not (Get-Service -Name $Service | Where-Object {$_.StartType -eq "Disabled"})) {
        $DisplayName = $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
        $Choices = @(
            (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Disable Service"),
            (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
        )
        $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $DisplayName -Message ($Messages."Disable Service: {0}?" -f $DisplayName)
        switch ($Choice) {
            0 {
                Get-Service -Name $Service | Set-Service -StartupType Disabled
                Get-Service -Name $Service | Set-Service -Status Stopped -ErrorAction SilentlyContinue
            }
        }
    } elseif (Get-Service -Name $Service | Where-Object {$_.StartType -eq "Disabled"}) {
        $DisplayName = $(Get-Service -Name $Service | Select-Object -ExpandProperty DisplayName)
        $Messages."You already disabled the following Service: {0}" -f $DisplayName
    }
}

# HomeProvider
# OneDrive
# Telemetry
# TimeServer

# XBox Game Overlay UI and Game DVR

$AppCaptureEnabled = Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR -Name AppCaptureEnabled -ErrorAction SilentlyContinue
$GameDVR_Enabled = Get-ItemProperty -Path HKCU:\System\GameConfigStore -Name GameDVR_Enabled -ErrorAction SilentlyContinue

if ($AppCaptureEnabled -eq 1 -or $GameDVR_Enabled -eq 1) {
    $Choices = @(
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Disable XBox Game DVR"),
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
    )
    $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $Messages."XBox Game DVR" -Message $Messages."Disable XBox Game DVR?"
    switch ($Choice) {
        0 {
            Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR -Name AppCaptureEnabled -Value 0
            Set-ItemProperty -Path HKCU:\System\GameConfigStore -Name GameDVR_Enabled -Value 0
        }
    }
} else {
    if (-not $AppCaptureEnabled) {
        New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR -Name AppCaptureEnabled -Value 0 -PropertyType DWORD
    }
    if (-not $GameDVR_Enabled) {
        New-ItemProperty -Path HKCU:\System\GameConfigStore -Name GameDVR_Enabled -Value 0
    }
    $Messages."You already disabled XBox Game DVR"
}


Read-Host -Prompt $Messages."You are done, press enter to exit"
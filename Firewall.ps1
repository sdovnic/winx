if ($PSVersionTable.PSVersion.Major -lt 3) {
    [String] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
    [String] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
}

Import-LocalizedData -BaseDirectory $PSScriptRoot\Locales -BindingVariable Messages

Import-Module -Name (Join-Path -Path $PSScriptRoot\Modules -ChildPath Get-Choice)

if (-not (Get-NetFirewallRule -Name "Secure Shell" -ErrorAction SilentlyContinue)) {
    $DisplayName = "Secure Shell"
    $Choices = @(
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."Yes"), $Messages."Allow"),
        (New-Object -TypeName System.Management.Automation.Host.ChoiceDescription -ArgumentList ("&{0}" -f $Messages."No"), $Messages."Do nothing")
    )
    $Choice = Get-Choice -Choices $Choices -Default 1 -Caption $DisplayName -Message ($Messages."Allow all traffic for the Secure Shell Protocol?")
    switch ($Choice) {
        0 {
            New-NetFirewallRule -Name "Secure Shell" -DisplayName "Secure Shell" -Enabled True -Profile Any -Direction Outbound -Action Allow -Protocol "TCP" -RemotePort 22
        }
    }
} else {
    $Messages."You allready allowed all traffic for the Secure Shell Protocol."
}

pause

if (-not (Get-NetFirewallRule -Name "Secure Shell" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt $messages."Allow all traffic for the Secure Shell Protocol? [y/N]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "Secure Shell" -DisplayName "Secure Shell" -Enabled True -Profile Any -Direction Outbound -Action Allow -Protocol "TCP" -RemotePort 22
    }
    Remove-Variable -Name question
}

if (-not (Get-NetFirewallRule -Name "W32Time" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt $messages."Allow the W32Time Service to contact a Network Time Server? [y/n]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "W32Time" -DisplayName "W32Time" -Enabled True -Profile Any -Direction Outbound -Action Allow -Service W32Time
    }
    Remove-Variable -Name question
}

if (-not (Get-NetFirewallRule -Name "Advanced TCP/IP Printer Port" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt $messages."Allow this Computer to contact a Network Printer in your local subnet [y/N]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "Advanced TCP/IP Printer Port" -DisplayName "Advanced TCP/IP Printer Port" -Enabled True -Profile Any -Direction Outbound -Action Allow -RemoteAddress LocalSubnet -RemotePort 9100 -Protocol "TCP"
    }
    Remove-Variable -Name question
}

if (-not (Get-NetFirewallRule -Name "Domain Name Server" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt $messages."Allow this Computer to contact a Domain Name Server in your local subnet [y/N]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "Domain Name Server" -DisplayName "Domain Name Server" -Enabled True -Profile Any -Direction Outbound -Action Allow -RemoteAddress LocalSubnet -RemotePort 53 -Protocol "UDP"
    }
    Remove-Variable -Name question
}

Read-Host -Prompt $messages."You are done, press enter to exit"

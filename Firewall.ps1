if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
}
if ($PSVersionTable.PSVersion.Major -lt 3) {
    [string] $PSCommandPath = $MyInvocation.MyCommand.Definition
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
    return
}

"Default Answer is No."

if (-not (Get-NetFirewallRule -Name "Secure Shell" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt "Allow all Secure Shell Traffic from this Machine [y/N]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "Secure Shell" -DisplayName "Secure Shell" -Enabled True -Profile Any -Direction Outbound -Action Allow -Protocol "TCP" -RemotePort 22
    }
    Remove-Variable -Name question
}

if (-not (Get-NetFirewallRule -Name "W32Time" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt "Allow the W32Time Service to contact a Network Time Server [y/N]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "W32Time" -DisplayName "W32Time" -Enabled True -Profile Any -Direction Outbound -Action Allow -Service W32Time
    }
    Remove-Variable -Name question
}

if (-not (Get-NetFirewallRule -Name "Advanced TCP/IP Printer Port" -ErrorAction SilentlyContinue)) {
    $question = Read-Host -Prompt "Allow this Machine to contact a Network Printer in your local Subnet [y/n]"
    if (($question.ToLower() -eq "y") -or ($question.ToLower() -eq "j")) {
        New-NetFirewallRule -Name "Advanced TCP/IP Printer Port" -DisplayName "Advanced TCP/IP Printer Port" -Enabled True -Profile Any -Direction Outbound -Action Allow -RemoteAddress LocalSubnet -RemotePort 9100 -Protocol "TCP"
    }
    Remove-Variable -Name question
}

Read-Host -Prompt "You are done press enter to exit"

function Set-HomeGroup {
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Disable", "Enable", "Status")] [String] $Action
    )
    Process {
        if ($Action.Contains("Disable")) {
            Set-Service -Name HomeGroupListener -StartupType Disabled
            Set-Service -Name HomeGroupProvider -StartupType Disabled
            $Restart = $true
        } elseif ($Action.Contains("Enable")) {
            Set-Service -Name HomeGroupListener -StartupType Automatic -Status Running
            Set-Service -Name HomeGroupProvider -StartupType Automatic -Status Running
        } elseif ($Action.Contains("Status")) {
            Get-Service -Name HomeGroupListener
            Get-Service -Name HomeGroupProvider
        }
    }
}
function Set-Cortana {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore", "Status")] [String] $Action
    )
    Process {
        $Path = "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowCortana" -Value "0" -Force
            Set-ItemProperty -Path $Path -Name "DisableWebSearch" -Value "1" -Force
            Set-ItemProperty -Path $Path -Name "AllowSearchToUseLocation" -Value "0" -Force
            Set-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb" -Value "0" -Force
        } elseif ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowCortana"
            Remove-ItemProperty -Path $Path -Name "DisableWebSearch"
            Remove-ItemProperty -Path $Path -Name "AllowSearchToUseLocation"
            Remove-ItemProperty -Path $Path -Name "ConnectedSearchUseWeb"
        } elseif ($Action.Contains("Status")) {
            if (Get-ItemProperty -Path $Path -Name "DisableWebSearch" -ErrorAction SilentlyContinue) {
                return $false
            } else {
                return $true
            }
        }
    }
}
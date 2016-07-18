function Set-Telemetry {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Disable", "Restore", "Status")] [String] $Action
    )
    Process {
        $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if ($Action.Contains("Disable")) {
            Set-ItemProperty -Path $Path -Name "AllowTelemetry" -Value "0"
        } elseif ($Action.Contains("Restore")) {
            Remove-ItemProperty -Path $Path -Name "AllowTelemetry"
        } elseif ($Action.Contains("Status")) {
            if (Get-ItemProperty -Path $Path -Name "AllowTelemetry" -ErrorAction SilentlyContinue) {
                return $false
            } else {
                return $true
            }
        }
    }
}
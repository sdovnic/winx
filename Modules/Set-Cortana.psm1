function Set-Cortana {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Disable", "Enable", "Status")] [String] $Action
    )
    Begin {
        $Path = "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Experience"
    }
    Process {
        if ($Action.Contains("Disable")) {
            if (Test-Path -Path $Path) {
                Set-ItemProperty -Path $Path -Name "AllowCortana" -Value 0 -Type DWord -Force
            }
        } elseif ($Action.Contains("Enable")) {
            if (-not (Test-Path -Path $Path)) {
                New-Item -Path $Path -Force
            }
            Set-ItemProperty -Path $Path -Name "AllowCortana" -Value 1 -Type DWord -Force
        } elseif ($Action.Contains("Status")) {
            if ((Get-ItemPropertyValue -Path $Path -Name "AllowCortana" -ErrorAction SilentlyContinue) -eq 1) {
                return $true
            } else {
                return $false
            }
        }
    }
}
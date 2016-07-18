function Set-ApplicationFirewallGroup {
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("False", "True")] [String] $Enabled,
        [Parameter(Mandatory=$true)] [String] $Group
    )
    Process {
        if (Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue) {
            if ($Enabled.Contains("False")) {
                Write-Verbose -Message "Disabling Group: $Group"
                Set-NetFirewallRule -Group $Group -Enabled False
            } elseif ($Enabled.Contains("True")) {
                Write-Verbose -Message "Enabling Group: $Group"
                Set-NetFirewallRule -Group $Group -Enabled True
            }
        } else {
            Write-Debug -Message "Group: $Group is not present."
        }
    }
}
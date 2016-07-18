function Set-Application {
    Param (
        [Parameter(Mandatory=$true)] [ValidateSet("Remove", "Install")] [String] $Action,
        [Parameter(Mandatory=$true)] [String] $Application
    )
    Process {
        if ($Action.Contains("Remove")) {
            If (Get-AppxPackage -Name $Application) {
                Get-AppxPackage -Name "$Application" | Remove-AppxPackage
            } else {
                Write-Debug -Message "$Application is not present."
            }
        } elseif ($Action.Contains("Install")) {
            if (Get-AppxPackage -AllUsers -Name "$Application") {
                Get-AppxPackage -AllUsers -Name "$Application" | Foreach-Object { $_.Name; Add-AppxPackage -Path “$($_.InstallLocation)\AppXManifest.xml” -Register -DisableDevelopmentMode -ErrorAction SilentlyContinue; }
            } else {
                Write-Debug -Message "$Application could not be installed. Please use the Microsoft Store."
            }
        }
    }
}
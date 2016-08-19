function Get-Choice {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false)] [String] $Caption = "",
        [Parameter(Mandatory=$false)] [String] $Message = "",
        [Parameter(Mandatory=$false)] [Int] $Default = -1,
        [Parameter(Mandatory=$true)] [Array] $Choices 
    )
    Begin {
        $ChoiceDescription = [System.Management.Automation.Host.ChoiceDescription[]] $Choices
    }
    Process {
        return $Host.UI.PromptForChoice($Caption, $Message, $ChoiceDescription, $Default)
    }
}

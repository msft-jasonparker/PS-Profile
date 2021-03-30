Function Update-AzContext {
    [CmdletBinding()]
    Param()

    Function Show-Menu {
        Param(
            [string]$Menu,
            [string]$Title = $(Throw [System.Management.Automation.PSArgumentNullException]::new("Title")),
            [switch]$ClearScreen,
            [Switch]$DisplayOnly,
            [ValidateSet("Full","Mini","Info")]
            $Style = "Full",
            [ValidateSet("White","Cyan","Magenta","Yellow","Green","Red","Gray","DarkGray")]
            $Color = "Gray"
        )
        if ($ClearScreen) {[System.Console]::Clear()}
    
        If ($Style -eq "Full") {
            #build the menu prompt
            $menuPrompt = "/" * (95)
            $menuPrompt += "`n`r////`n`r//// $Title`n`r////`n`r"
            $menuPrompt += "/" * (95)
            $menuPrompt += "`n`n"
        }
        ElseIf ($Style -eq "Mini") {
            #$menuPrompt = "`n"
            $menuPrompt = "\" * (80)
            $menuPrompt += "`n\\\\  $Title`n"
            $menuPrompt += "\" * (80)
            $menuPrompt += "`n"
        }
        ElseIf ($Style -eq "Info") {
            #$menuPrompt = "`n"
            $menuPrompt = "-" * (80)
            $menuPrompt += "`n-- $Title`n"
            $menuPrompt += "-" * (80)
        }
    
        #add the menu
        $menuPrompt+=$menu
    
        [System.Console]::ForegroundColor = $Color
        If ($DisplayOnly) {Write-Host $menuPrompt}
        Else {Read-Host -Prompt $menuprompt}
        [system.console]::ResetColor()
    }

    Write-Verbose "Getting Azure Subscriptions..."
    $Subs = Get-AzSubscription -Verbose:$false -Debug:$false | % {$_.Name} | Sort-Object
    Write-Verbose ("Found {0} Azure Subscriptions" -f $Subs.Count)
    $SubSelection = (@"
`n
"@)
    $SubRange = 0..($Subs.Count - 1)
    For ($i = 0; $i -lt $Subs.Count;$i++) {$SubSelection += " [$i] $($Subs[$i])`n"}
    $SubSelection += "`n Please select a Subscription"

    Do {$SubChoice = Show-Menu -Title "Select an Azure Subscription" -Menu $SubSelection -Style Full -Color White -ClearScreen}
    While (($SubRange -notcontains $SubChoice) -OR (-NOT $SubChoice.GetType().Name -eq "Int32"))
    
    Write-Verbose ("Updating Azure Subscription to: {0}" -f $Subs[$SubChoice])
    Select-AzSubscription -Subscription $Subs[$SubChoice] -Verbose:$false -Debug:$false | Out-Null
    Clear-Host
}

Set-Alias -Name uac -Value Update-AzContext -Description "Gets the current Azure Subscriptions and creates a menu to change the current subscription."

function prompt {
    $DebugPreference = "SilentlyContinue"
    $AzureContext = Get-AzContext -ErrorAction SilentlyContinue -Verbose:$false -Debug:$false
    $location = Get-Location -Verbose:$false -Debug:$false
    $locSplit = $location.Path.Split("\")
    If ($locSplit.Count -le 3) { $currentPath = $location.Path }
    Else { $currentPath = ("{0}{1}\{2}\{3}" -f $locSplit[0],("\.." * ($locSplit.count - 3)),$locSplit[-2],$locSplit[-1]) }

    If ($AzureContext) {
        $SubName = $AzureContext.Name.Split("(")[0].Trim(" ")
           $Environment = $AzureContext.Environment
           $SubId = $AzureContext.Subscription.id
           $Account = $AzureContext.Account.Id
           ($host.UI.Write("[") + $host.UI.Write("Cyan", $host.UI.RawUI.BackGroundColor, $SubName) + $host.UI.Write(" - ") + $host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, $SubId) + "]`n[$Environment - $Account] " + $currentPath + '>')
    }
    Else {$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[NotConnected] ") + $currentPath + '>'}
}

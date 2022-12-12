[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Organization,
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [Parameter(Mandatory = $true)]
    [securestring]$Pat
)
# Installation PowerShell Module
Write-Host "Installing and update latest PSDevOps cmdlets"
Install-Module -Name PSDevOps -Scope CurrentUser
Update-Module -Name PSDevOps
Import-Module -Name PSDevOps
Write-Host "Installed latest version of PSDevOps"

# Verbindung herstellen
$apiVersion = "6.0"
$patPlainText = ConvertFrom-SecureString $Pat -AsPlainText
Connect-ADO -Organization $Organization -PersonalAccessToken $patPlainText

# Work Items abfragen 
$query = "Select [System.ID],[System.Title],[Microsoft.VSTS.Common.Priority] from WorkItems where [Changed Date] >= @StartofDay('-30d')"
$workitems = Get-ADOWorkItem -Project $Project -Query "$query" -ApiVersion $apiVersion -Fields Microsoft.VSTS.Common.Priority,System.Title

foreach ($workItem in $workitems) {
    write-host "Updating work item $($workItem.ID) - $($workitem."System.Title")"
    $oldValue = $workItem."Microsoft.VSTS.Common.Priority";
    $newValue = 1;
    Write-Host "Old priority: $($oldPrio)"
    Write-Host "New priority: $($newPrio)"
    
    # Work Item bearbeiten
    Set-ADOWorkItem -Project $teamProjectName -ID $workItem.ID -ApiVersion $apiVersion -Tag 'UpdatedByPrioritizeScript' -InputObject @{
        "Microsoft.VSTS.Common.Priority" = $newPrio;}
    Write-Host "Update was successful"
}

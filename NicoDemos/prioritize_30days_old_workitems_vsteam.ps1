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
Write-Host "Installing and update latest VSTeam cmdlets"
Install-Module -Name VSTeam -Repository PSGallery -Scope CurrentUser
Update-Module -Name VSTeam
Import-Module -Name VSTeam
Write-Host "Installed latest version of VSTeam"

# Verbindung herstellen
$patPlainText = ConvertFrom-SecureString $Pat -AsPlainText
Set-VSTeamAccount -Account $Organization -PersonalAccessToken $patPlainText
Set-VSTeamDefaultProject $Project

# Work Items abfragen
$query = "Select [System.ID],[System.Title],[Microsoft.VSTS.Common.Priority] from WorkItems where [Changed Date] >= @StartofDay('-30d')"
$workitems = Get-VSTeamWiql -ProjectName $Project -Query "$query"

foreach ($workItemID in $workitems.WorkItemIDs) {
    $workitem = Get-VSTeamWorkItem -Id $workItemID -Fields Microsoft.VSTS.Common.Priority,System.Title
    write-host "Updating work item $($workItem.ID) - $($workitem.fields."System.Title")"
    $oldPrio = $workItem.fields."Microsoft.VSTS.Common.Priority";
    $newPrio = 1
    Write-Host "Old priority: $($oldPrio)"
    Write-Host "New priority: $($newPrio)"

    # Work Item bearbeiten
    $additionalFields = @{"System.Tags"= "UpdatedByPrioritizeScript"; "Microsoft.VSTS.Common.Priority" = $newPrio}
    Update-VSTeamWorkItem -ID $workItem.ID -AdditionalFields $additionalFields
    Write-Host "Update was successful"
}

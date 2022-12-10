[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$teamProjectName,
    [Parameter(Mandatory=$true)]
    [string]$organisationName,
    [Parameter(Mandatory=$true)]
    [SecureString]$pat)

Write-Host "Installing and update latest VSTeam cmdlets"
Install-Module -Name VSTeam -Repository PSGallery -Scope CurrentUser
Update-Module -Name VSTeam
Import-Module -Name VSTeam
Write-Host "Installed latest version of VSTeam"

$patPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat))
Set-VSTeamAccount -Account $organisationName -PersonalAccessToken $patPlainText -verbose
Set-VSTeamDefaultProject $teamProjectName

$query = "Select [System.ID],[System.Title],[Microsoft.VSTS.Common.Priority] from WorkItems where [Changed Date] >= @StartofDay('-30d')"
$workitems = Get-VSTeamWiql -ProjectName $teamProjectName -Query "$query"

foreach ($workItemID in $workitems.WorkItemIDs) {
    $workitem =  Get-VSTeamWorkItem -Id $workItemID -Fields Microsoft.VSTS.Common.Priority,System.Title

    write-host "Updating work item $($workItem.ID) - $($workitem.fields."System.Title")" -ForegroundColor Green
    $oldValue = $workItem.fields."Microsoft.VSTS.Common.Priority";
    $newValue = 1;

    Write-Host "Old priority: $($oldValue)"
    Write-Host "New priority: $($newValue)"

    $additionalFields = @{"System.Tags"= "UpdatedByPrioritizeScript"; "Microsoft.VSTS.Common.Priority" = $newValue}

    Update-VSTeamWorkItem -ID $workItem.ID -AdditionalFields $additionalFields

    Write-Host "Update was successful." -ForegroundColor Green
}

#https://www.powershellgallery.com/packages/PSDevOps/0.5.4.2

[CmdletBinding()]
param (
    [string]
    $teamProjectName,
    [string]
    $collectionName,
    [string]
    $pat
)



Install-Module -Name PSDevOps -Verbose

#$serverUrl = "https://devtfs2019/tfs";
$apiVersion = "5.0";

#$query = "Select [System.ID],[Microsoft.VSTS.Scheduling.Effort] from WorkItems where [Changed Date] >= @StartofDay('-14d') and [Changed Date] <= @StartofDay('-7d')"
$query = "Select [System.ID],[Microsoft.VSTS.Scheduling.Effort] from WorkItems where [Changed Date] >= @StartofDay('-1')"

$workitems = Get-ADOWorkItem -Organization $collectionName -Project $teamProjectName -Query "$query" -PAT $pat -ApiVersion $apiVersion -Fields Microsoft.VSTS.Scheduling.Effort,System.Title,System.Id

foreach ($workItem in $workitems) {
    write-host "Updating work item $workItem" -ForegroundColor Green
    $oldValue = $workItem."Microsoft.VSTS.Scheduling.Effort";

    Write-Host "Old effort: $($oldValue)"
    $newValue = $oldValue + 2;

    Write-Host "New effort: $($newValue)"

    Set-ADOWorkItem -Organization $collectionName -Project $teamProjectName -ID $workItem.ID -ApiVersion $apiVersion -PAT $pat -InputObject @{
        "Microsoft.VSTS.Scheduling.Effort" = $newValue;
        "System.State" = 'Approved';}

    Write-Host "Update was sucessfull." -ForegroundColor Green
}

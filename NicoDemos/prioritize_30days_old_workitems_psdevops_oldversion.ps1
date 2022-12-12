[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$teamProjectName,
    [Parameter(Mandatory=$true)]
    [string]$organisationName,
    [Parameter(Mandatory=$true)]
    [SecureString]$pat)

Write-Host "Installing and update latest PSDevOps cmdlets"
Install-Module -Name PSDevOps -Scope CurrentUser
Update-Module -Name PSDevOps
Import-Module -Name PSDevOps
Write-Host "Installed latest version of PSDevOps"
$apiVersion = "6.0";

$patPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pat))
Connect-ADO -Organization $organisationName -PersonalAccessToken $patPlainText -verbose 

$query = "Select [System.ID],[System.Title],[Microsoft.VSTS.Common.Priority] from WorkItems where [Changed Date] >= @StartofDay('-30d')"
$workitems = Get-ADOWorkItem  -Project $teamProjectName -Query "$query" -ApiVersion $apiVersion -Fields Microsoft.VSTS.Common.Priority,System.Title
foreach ($workItem in $workitems) {
    write-host "Updating work item $($workItem.ID) - $($workitem."System.Title")" -ForegroundColor Green
    $oldValue = $workItem."Microsoft.VSTS.Common.Priority";
    $newValue = 1;

    Write-Host "Old priority: $($oldValue)"
    Write-Host "New priority: $($newValue)"

    Set-ADOWorkItem -Project $teamProjectName -ID $workItem.ID -ApiVersion $apiVersion -Tag 'UpdatedByPrioritizeScript' -InputObject @{
        "Microsoft.VSTS.Common.Priority" = $newValue;}

    Write-Host "Update was successful." -ForegroundColor Green
}

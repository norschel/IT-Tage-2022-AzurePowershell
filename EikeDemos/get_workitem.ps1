<#
    .SYNOPSIS
    Fetch a work item by id

    .EXAMPLE
    PS> get_workitem -organization myOrg -project myProject -id 1337
#>

[CmdletBinding()]
param(
    # Azure DevOps Services organization url
    [Parameter(Mandatory = $true)]
    [string]$organization,
	# Azure DevOps project
    [Parameter(Mandatory = $true)]
    [string]$project,
    # Work item ID
    [Parameter(Mandatory = $true)]
    [string]$id,
    # Azure DevOps PAT
    [Parameter(Mandatory = $false)]
    [string]$pat = $env:AZURE_DEVOPS_EXT_PAT
)

if ([string]::IsNullOrEmpty($pat)){
    throw "Please specify a Personal Access Token as parameter '-pat' or environment variable 'AZURE_DEVOPS_EXT_PAT'"
}

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("PAT:$($pat)"))
$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

Write-Host "Fetch work item #$id"
# https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/get-work-item?view=azure-devops-rest-6.0
$apiUri = "{0}/{1}/_apis/wit/workitems/{2}?api-version=6.0" -f $organization, $project, $id

$response = Invoke-WebRequest -Uri $apiUri -Headers $Headers

$content = $response.Content | ConvertFrom-Json

if ($response.StatusCode -eq 200){
	Write-Host ("- Work Item Type: {0}" -f $content.fields.'System.WorkItemType')
    Write-Host ("- Title: {0}" -f $content.fields.'System.Title')
    Write-Host ("- State: {0}" -f $content.fields.'System.State')
}

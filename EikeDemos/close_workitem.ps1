<#
    .SYNOPSIS
    Close a work item by id

    .EXAMPLE
    PS> close_workitem -organization myOrg -project myProject -id 1337
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

$body = 
'[
    {  
        "op": "add",
        "path": "/fields/System.State",
        "value": "Done"
    }
]'

Write-Host "Close work item #$id"
# https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/update?view=azure-devops-rest-6.0
$apiUri = "{0}/{1}/_apis/wit/workitems/{2}?api-version=6.0" -f $organization, $project, $id

Invoke-WebRequest -Uri $apiUri -Headers $Headers -ContentType "application/json-patch+json" -Method Patch -Body $body

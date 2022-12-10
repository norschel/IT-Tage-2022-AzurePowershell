<#
    .SYNOPSIS
    Create a bug with title "Hello Basta"

    .EXAMPLE
    PS> create_bug -organization myOrg -project myProject -message "Hello World!"
#>

[CmdletBinding()]
param(
    # Azure DevOps Services organization url
    [Parameter(Mandatory = $true)]
    [string]$organization,
	# Azure DevOps project
    [Parameter(Mandatory = $true)]
    [string]$project,
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
        "path": "/fields/System.Title",
        "value": "Hello Basta"
    }
]'

Write-Host "Create new bug"
# https://docs.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create?view=azure-devops-rest-6.0
$apiUri = "{0}/{1}/_apis/wit/workitems/`$Bug?api-version=6.0" -f $organization, $project
$response = Invoke-WebRequest -Uri $apiUri -Headers $Headers -ContentType "application/json-patch+json" -Method Post -Body $body

$content = $response.Content | ConvertFrom-Json

if ($response.StatusCode -eq 200){
	Write-Host "- Bug #$($content.id) created"
}

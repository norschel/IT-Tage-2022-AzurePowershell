<#
    .SYNOPSIS
    Add a file to a git repository

    .EXAMPLE
    PS> git_add_file -organization myOrg -project myProject -repoId 1337
#>

[CmdletBinding()]
param(
    # Azure DevOps Services organization url
    [Parameter(Mandatory = $true)]
    [string]$organization,
	  # Azure DevOps project
    [Parameter(Mandatory = $true)]
    [string]$project,
    # Git repo ID
    [Parameter(Mandatory = $true)]
    [string]$repoId,
    # Git branch
    [Parameter(Mandatory = $false)]
    [string]$branch = "main",
    # Content of added file
    [Parameter(Mandatory = $false)]
    [string]$fileContent = "Hello Basta!",
    # Content of added file
    [Parameter(Mandatory = $false)]
    [string]$fileName = "added-file.md",
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

# Get ref
# https://docs.microsoft.com/en-us/rest/api/azure/devops/git/refs/list?view=azure-devops-rest-6.0
$apiUri = "{0}/{1}/_apis/git/repositories/{2}/refs?includeMyBranches={3}&api-version=6.0" -f $organization, $project, $repoId, $branch
$response = Invoke-WebRequest -Uri $apiUri -Headers $Headers -Method Get

$content = $response.Content | ConvertFrom-Json

$oldObjectId = $content.value[0].objectId

$body = "{
    'refUpdates': [
      {
        'name': 'refs/heads/$branch',
        'oldObjectId': '$oldObjectId'
      }
    ],
    'commits': [
      {
        'comment': 'Added $fileName',
        'changes': [
          {
            'changeType': 'add',
            'item': {
              'path': '/$fileName'
            },
            'newContent': {
              'content': '#$fileContent',
              'contentType': 'rawtext'
            }
          }
        ]
      }
    ]
  }"

# push file
# https://docs.microsoft.com/en-us/rest/api/azure/devops/git/pushes/create?view=azure-devops-rest-6.0
$apiUri = "{0}/{1}/_apis/git/repositories/{2}/pushes?api-version=6.0" -f $organization, $project, $repoId
Invoke-WebRequest -Uri $apiUri -Headers $Headers -Method Post -Body $body -ContentType "application/json"

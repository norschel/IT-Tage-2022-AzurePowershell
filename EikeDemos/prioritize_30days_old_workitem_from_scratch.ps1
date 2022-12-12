[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Organization,
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [Parameter(Mandatory = $true)]
    [securestring]$Pat
)

# Authentifizierungs-Header erzeugen
$pat64 = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("PAT:$(ConvertFrom-SecureString $Pat -AsPlainText)"))
$headers = @{
    'Authorization' = 'Basic ' + $pat64
}

# Work Items abfragen
$apiUri = "https://dev.azure.com/$($Organization)/$($Project)/_apis/wit/wiql?api-version=6.0"
$body = @{query= "Select [System.ID] From workitems Where [Changed Date] >= @StartofDay('-30d')"} | ConvertTo-Json
$response = Invoke-WebRequest -Uri $apiUri -Method Post -Headers $headers -Body $body -ContentType "application/json"
$workItemIds = ($response.Content | ConvertFrom-Json).workitems.id

foreach ($workItemId in $workItemIds) {
    # Work Item bearbeiten
    Write-Host "Updating work item #$workItemId"
    $apiUri = "https://dev.azure.com/$($Organization)/$($Project)/_apis/wit/workitems/$($workItemId)?api-version=6.0"
    $body = 
    '[
        {
            "op": "add",
            "path": "/fields/Microsoft.VSTS.Common.Priority",
            "value": "1"
        },
        {
            "op": "add",
            "path": "/fields/System.Tags",
            "value": "UpdatedByPrioritizeScript"
        }
    ]'
    $response = Invoke-WebRequest -Uri $apiUri -Method Patch -Headers $headers -Body $body -ContentType "application/json-patch+json"
    Write-Host "Update was successful"
}

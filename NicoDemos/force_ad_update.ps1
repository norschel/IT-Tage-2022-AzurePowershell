[CmdletBinding()]
param (

[uri]
$ServerUri
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

[Reflection.Assembly]::LoadFrom('C:\Program Files\Azure DevOps Server 2020\Tools\Microsoft.TeamFoundation.Client.dll')

$Server = [Microsoft.TeamFoundation.Client.TfsConfigurationServerFactory]::GetConfigurationServer($ServerUri)
$Server.EnsureAuthenticated()
$JobService = $Server.GetService([Microsoft.TeamFoundation.Framework.Client.ITeamFoundationJobService])

$IdentitySyncJobId = [guid]'544dd581-f72a-45a9-8de0-8cd3a5f29dfe'
$IdentitySyncJobDef = $JobService.QueryJobs() |
Where-Object { $_.JobId -eq $IdentitySyncJobId }

if ($IdentitySyncJobDef) {
Write-Verbose "Queuing job '$($IdentitySyncJobDef.Name)' with high priority now"
$QueuedCount = $JobService.QueueJobNow($IdentitySyncJobDef, $true)
if ($QueuedCount -eq 0) {
Write-Error "Failed to queue job"
}
} else {
Write-Error "Could not find Periodic Identity Synchronization job definition (id $IdentitySyncJobId)."
}
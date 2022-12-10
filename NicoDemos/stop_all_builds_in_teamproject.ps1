# Thanks to https://stackoverflow.com/questions/57004926/how-can-i-cancel-all-previous-build-when-a-new-one-is-queued
# and https://gist.github.com/tegaaa/e14820ccf7ea99ba2ef9d0c3cc180df4
# https://www.imaginet.com/2019/how-use-azure-devops-rest-api-with-powershell/

$tfsUrl = "https://<toDo>";
$teamproject = "<ToDo>";

$personalToken = "";
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($personalToken)"))
$header = @{authorization = "Basic $token"}

$buildsUrl = "$($tfsUrl)/$($teamproject)/_apis/build/builds?api-version=5.0"
$builds = Invoke-RestMethod -Uri $buildsUrl -Method Get -Header $header -ContentType "application/json" 
$buildsToStop = $builds.value.Where({ ($_.status -eq 'notStarted')})
ForEach($build in $buildsToStop)
{
   $build.status = "Cancelling"
   $body = $build | ConvertTo-Json -Depth 10
   $urlToCancel = "$($tfsUrl)/$($teamproject)/_apis/build//builds/$($build.id)?api-version=5.0"
   Invoke-RestMethod -Uri $urlToCancel -Method Patch -ContentType application/json -Body $body -Header $header
}

inProgress
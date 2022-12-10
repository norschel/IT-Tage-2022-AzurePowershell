<#
    .SYNOPSIS
    Create a banner with az devops cli

    .EXAMPLE
    PS> new_banner -organization myOrg -message "Hello World!"
#>
[CmdletBinding()]
param(
    # Azure DevOps Services organization url
    [Parameter(Mandatory = $true)]
    [string]$organization,
    # Banner message
    [Parameter(Mandatory = $true)]
    [string]$message
)

if ([string]::IsNullOrEmpty($env:AZURE_DEVOPS_EXT_PAT)){
    throw "Please specify a Personal Access Token as environment variable 'AZURE_DEVOPS_EXT_PAT'"
}

# https://docs.microsoft.com/en-us/cli/azure/devops/admin/banner?view=azure-cli-latest#az-devops-admin-banner-add
az devops admin banner add --org $organization -m $message --type warning


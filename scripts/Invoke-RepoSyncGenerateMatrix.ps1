# Requires Environment Variables for GitHub Actions
# GH_TOKEN
# Must run gh auth login -h "GitHub.com" before running this script

param(
    [array]$repoFilter = @()
)

Write-Host "Generating matrix for AVM repositories"

$env:ARM_USE_AZUREAD = "true"
$repos = @()

Write-Host "Getting repositories from app installation"

# Get the list of installed repositories for the GitHub App
$itemsPerPage = 100
$page = 1
$incompleteResults = $true

$installedRepositories = @()

while($incompleteResults) {
  $response = ConvertFrom-Json $(gh api "/installation/repositories?per_page=$itemsPerPage&page=$page")
  $installedRepositories += $response.repositories
  $incompleteResults = $page * $itemsPerPage -lt $response.total_count
  $page++
}

foreach ($installedRepository in ($installedRepositories | Sort-Object -Property name)) {
  $moduleName = $installedRepository.name.Replace("terraform-azurerm-", "")
  if(!$moduleName.StartsWith("avm-")) {
    continue
  }

  $moduleType = $moduleName.Split("-")[1]

  if($moduleType -eq "res") {
    $moduleType = "resource"
  } elseif($moduleType -eq "ptn") {
    $moduleType = "pattern"
  } elseif($moduleType -eq "utl") {
    $moduleType = "utility"
  }

  $protectedRepos = Import-Csv "./protected_repos/ProtectedRepos.csv"

  $repos += @{
    repoId              = $moduleName
    repoUrl             = $installedRepository.html_url
    repoType            = "avm"
    repoSubType         = $moduleType
    repoOwnerTeam       = "@Azure/$($moduleName)-module-owners-tf"
    repoContributorTeam = "@Azure/$($moduleName)-module-contributors-tf"
    repoIsProtected     = $protectedRepos.ModuleName -contains $moduleName
  }
}

Write-Host "Filtering repositories"
if($repoFilter.Length -gt 0) {
    $repos = $repos | Where-Object { $repoFilter -contains $_.id }
}

Write-Host "Found $($repos.Count) repositories"

return $repos

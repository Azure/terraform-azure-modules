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

$validPrefixes = @("terraform-azurerm-", "terraform-azapi-")

foreach ($installedRepository in $installedRepositories) {

  $skipRepository = $true
  $moduleName = ""

  foreach($validPrefix in $validPrefixes) {
    if($installedRepository.name.StartsWith($validPrefix)) {
      $moduleName = $installedRepository.name.Replace($validPrefix, "")
      $skipRepository = $false
    }
  }

  if($skipRepository) {
    Write-Host "Skipping $($installedRepository.name) as it does not start with a valid prefix"
    continue
  }

  if(!$moduleName.StartsWith("avm-")) {
    Write-Host "Skipping $($installedRepository.name) as it does not start with avm-"
    continue
  }

  if($installedRepository.archived) {
    Write-Host "Skipping $($installedRepository.name) as it is archived"
    continue
  }

  $moduleType = $moduleName.Split("-")[1]

  if($moduleType -eq "res") {
    $moduleType = "resource"
  } elseif($moduleType -eq "ptn") {
    $moduleType = "pattern"
  } elseif($moduleType -eq "utl") {
    $moduleType = "utility"
  } else {
    Write-Host "Skipping $($installedRepository.name) as it does not have a valid module type"
    continue
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
    $repos = $repos | Where-Object { $repoFilter -contains $_.repoId }
}

Write-Host "Found $($repos.Count) repositories"

return $repos | Sort-Object -Property repoId

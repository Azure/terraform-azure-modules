# Requires Environment Variables for GitHub Actions
# GH_TOKEN
# Must run gh auth login -h "GitHub.com" before running this script

param(
    [array]$repoFilter = @(),
    [array]$validProviders = @("azure", "azurerm", "azapi"),
    [array]$reposToSkip = @(
      "bicep-registry-modules",
      "terraform-azure-modules",
      "ALZ-PowerShell-Module",
      "Azure-Verified-Modules",
      "terraform-azurerm-avm-template",
      "Azure-Verified-Modules-Grept",
      "avmtester",
      "tflint-ruleset-avm",
      "avm-gh-app",
      "avm-container-images-cicd-agents-and-runners",
      "Azure-Verified-Modules-Workflows"
    )
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

foreach ($installedRepository in $installedRepositories | Sort-Object -Property name) {
  if($reposToSkip -contains $installedRepository.name) {
    Write-Host "Skipping $($installedRepository.name) as it is in the skip list..."
    continue
  }

  if($installedRepository.archived) {
    Write-Warning "Skipping $($installedRepository.name) as it is archived..."
    continue
  }

  if(!$installedRepository.name.StartsWith("terraform-")) {
    Write-Warning "Skipping $($installedRepository.name) as it does not start with 'terraform-'..."
    continue
  }

  $skipRepository = $true
  $moduleName = ""

  foreach($validProvider in $validProviders) {
    $validPrefix = "terraform-$validProvider-"
    if($installedRepository.name.StartsWith($validPrefix)) {
      $moduleName = $installedRepository.name.Replace($validPrefix, "")
      $skipRepository = $false
    }
  }

  if($skipRepository) {
    Write-Warning "Skipping $($installedRepository.name) as it does not have a valid provider segment..."
    continue
  }

  if(!$moduleName.StartsWith("avm-")) {
    Write-Warning "Skipping $($installedRepository.name) as it does not have the 'avm' segment..."
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
    Write-Warning "Skipping $($installedRepository.name) as it does not have a valid module type segment..."
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

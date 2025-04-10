param(
  $client_id, # This is the Client ID of the GitHub App
  $private_key_path = "azure-verified-modules.pem" # This is the path to the private key for the GitHub App
)

# Authenticate with GitHub CLI using the GitHub App
./scripts/Connect-AsApp.ps1 -client_id $client_id -private_key_path $private_key_path

# Get the CSV Files
./scripts/Invoke-AvmRepoCsvDownload.ps1

# Get the list of installed repositories for the GitHub App
$repositories = ./scripts/Invoke-RepoSyncGenerateMatrix.ps1

$resourceModulesCSVData = Import-Csv -Path "./temp/TerraformResourceModules.csv"
$patternModulesCSVData = Import-Csv -Path "./temp/TerraformPatternModules.csv" 
$utilityModulesCSVData = Import-Csv -Path "./temp/TerraformUtilityModules.csv"

$metaDataVariables = @(
  @{
      key = "ProviderNamespace"
      name = "AVM_RESOURCE_PROVIDER_NAMESPACE"
  },
  @{
      key = "ResourceType"
      name = "AVM_RESOURCE_TYPE"
  },
  @{
      key = "ModuleDisplayName"
      name = "AVM_MODULE_DISPLAY_NAME"
  },
  @{
      key = "AlternativeNames"
      name = "AVM_MODULE_ALTERNATIVE_NAMES"
  },
  @{
      key = "Comments"
      name = "AVM_COMMENTS"
  },
  @{
      key = "PrimaryModuleOwnerGHHandle"
      name = "AVM_OWNER_PRIMARY_GITHUB_HANDLE"
  },
  @{
      key = "PrimaryModuleOwnerDisplayName"
      name = "AVM_OWNER_PRIMARY_DISPLAY_NAME"
  },
  @{
      key = "SecondaryModuleOwnerGHHandle"
      name = "AVM_OWNER_SECONDARY_GITHUB_HANDLE"
  },
  @{
      key = "SecondaryModuleOwnerDisplayName"
      name = "AVM_OWNER_SECONDARY_DISPLAY_NAME"
  }
)

foreach($repository in $repositories) {
  $repositoryCSVData = $null

  if($repository.repoSubType -eq "resource") {
    $repositoryCSVData = $resourceModulesCSVData | Where-Object { $_.ModuleName -eq $repository.repoId }
  }
  if($repository.repoSubType -eq "pattern") {
    $repositoryCSVData = $patternModulesCSVData | Where-Object { $_.ModuleName -eq $repository.repoId }
  }
  if($repository.repoSubType -eq "utility") {
    $repositoryCSVData = $utilityModulesCSVData | Where-Object { $_.ModuleName -eq $repository.repoId }
  }

  if($null -eq $repositoryCSVData) {
    Write-Warning "Repository $($repository.repoId) not found in CSV data"
    continue
  }

  Write-Host "Repository $($repository.repoId) found in CSV data" -ForegroundColor Green

  foreach($item in $metaDataVariables) {
    if(!$repositoryCSVData.PSObject.Properties.Name -contains $item.key) {
      Write-Host "Meta data item $($item.name) not found in CSV data for: $($repository.repoId)"
      continue
    }
    $metaDataItem = $repositoryCSVData.($item.key)
    
    Write-Host "Meta data item $($item.name) found for: $($repository.repoId)"

    if($null -eq $metaDataItem -or $metaDataItem -eq "") {
      Write-Host "Meta data item $($item.name) is null or empty for: $($repository.repoId)"
      continue
    }

    # Set the variable in the GitHub repository
    $cliCommand = "gh variable set `"$($item.name)`" --body `"$metaDataItem`" --repo `"$($repository.repoUrl)`""
    Write-Host "Running: $cliCommand" -ForegroundColor Blue
    gh variable set "$($item.name)" --body "$metaDataItem" --repo "$($repository.repoUrl)"
  }
}

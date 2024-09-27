# Requires Environment Variables for GitHub Actions
# GH_TOKEN
# ARM_USE_AZUREAD
# ARM_USE_OIDC
# ARM_TENANT_ID
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# Must run gh auth login -h "GitHub.com" before running this script

param(
    [string]$stateStorageAccountName = "stoavmstate",
    [string]$stateResourceGroupName = "rg-avm-state",
    [string]$stateContainerName = "avm-state",
    [array]$repoFilter = @("avm-res-network-virtualnetwork", "avm-res-network-connection"),
    [bool]$planOnly = $false,
    [bool]$firstRun = $false,
    [array]$csvFiles = @( 
        @{
            path = "./temp/TerraformResourceModules.csv"
            type = "avm"
            subtype = "resource"
        },
        @{
            path = "./temp/TerraformPatternModules.csv"
            type = "avm"
            subtype = "pattern"
        },
        @{
            path = "./temp/TerraformUtilityModules.csv"
            type = "avm"
            subtype = "utility"
        },
        @{
            path = "./legacy_repos/LegacyRepos.csv"
            type = "legacy"
            subtype = "legacy"
        }
    )
)

$env:ARM_USE_AZUREAD = "true"
$repos = @()

foreach ($csvFile in $csvFiles) {
  $reposFromFile = Import-Csv $($csvFile.path)
  foreach ($repoFromFile in $reposFromFile) {
    $repos += @{
      id              = $repoFromFile.ModuleName
      url             = $repoFromFile.RepoURL
      type            = $csvFile.type
      subtype         = $csvFile.subtype
      ownerTeam       = $repoFromFile.ModuleOwnersGHTeam
      contributorTeam = $repoFromFile.ModuleContributorsGHTeam
    }
  }
}

if($repoFilter.Length -gt 0) {
    $repos = $repos | Where-Object { $repoFilter -contains $_.id }
}

$secretNames = @("ARM_TENANT_ID", "ARM_SUBSCRIPTION_ID", "ARM_CLIENT_ID")

foreach($repo in $repos) {
    if(Test-Path "imports.tf") {
        Remove-Item "imports.tf" -Force
    }

    if(Test-Path ".terraform") {
        Remove-Item ".terraform" -Recurse -Force
    }

    $repoUrl = $repo.url
    $repoSplit = $repoUrl.Split("/")
    $orgName = $repoSplit[3]
    $repoName = $repoSplit[4]
    $orgAndRepoName = "$orgName/$repoName"

    $existingRepo = $(gh api "repos/$orgAndRepoName" 2> $null) | ConvertFrom-Json

    if ($existingRepo.status -eq 404) {
        Write-Warning "Skipping: $orgAndRepoName has not been created yet."

    } else {
        Write-Host "<--->" -ForegroundColor Green
        Write-Host "$([Environment]::NewLine)Updating: $orgAndRepoName.$([Environment]::NewLine)" -ForegroundColor Green
        Write-Host "<--->" -ForegroundColor Green

        $existingEnvironment = $(gh api "repos/$orgAndRepoName/environments/test" 2> $null) | ConvertFrom-Json

        if (($existingEnvironment.status -ne 404) -and ($repo.type -eq "avm") -and $firstRun) {
            Write-Host "First Run: Taking ownership of test environevent for $orgAndRepoName"
                $import = @"
import {
    to = github_repository_environment.this[0]
    id = "$($repoName):test"
}

"@
            
                Add-Content -Path "imports.tf" -Value $import

                foreach($secretName in $secretNames) {
                    $existingSecret = $(gh api "repos/$orgAndRepoName/environments/test/secrets/$secretName" 2> $null) | ConvertFrom-Json
                    if($existingSecret.status -ne 404) {
                        
                        if(!$planOnly) {
                            Write-Host "Deleting secret: $secretName"
                            gh api -X DELETE "repos/$orgAndRepoName/environments/test/secrets/$secretName"
                        } else {
                            Write-Host "Planning to delete secret: $secretName"
                        }
                    }
                }
        }

        terraform init `
            -backend-config="resource_group_name=$stateResourceGroupName" `
            -backend-config="storage_account_name=$stateStorageAccountName" `
            -backend-config="container_name=$stateContainerName" `
            -backend-config="key=$($repo.id).tfstate"

        terraform plan -out="$($repo.id).tfplan" `
            -var="github_repository_owner=$orgName" `
            -var="github_repository_name=$repoName" `
            -var="github_owner_team_name=$($repo.ownerTeam)" `
            -var="manage_github_environment=$(($repo.type -eq "avm").ToString().ToLower())"

        $plan = $(terraform show -json "$($repo.id).tfplan") | ConvertFrom-Json

        $hasDestroy = $false
        foreach($resource in $plan.resource_changes) {
            if($resource.change.actions -contains "destroy") {
                Write-Error "Planning to destroy: $($resource.address)"
                $hasDestroy = $true
            }
        }

        if(!$hasDestroy -and !$planOnly -and !$plan.errored) {
            terraform apply "$($repo.id).tfplan"
        }
    }
}

param(
    [array]$repositories = @()
)

$repositoryData = @()
$warnings = @()

foreach($repository in $repositories) {
    $repoId = $repository.repoId
    $repoUrl = $repository.repoUrl
    $repoSplit = $repoUrl.Split("/")

    $orgName = $repoSplit[3]
    $repoName = $repoSplit[4]

    $repoSplit = $repoName.Split("-")
    $providerName = $repoSplit[1]
    $orgAndRepoName = "$orgName/$repoName"

    # Meta Data
    $metaDataVariables = @(
        @{
            key = "providerNamespace"
            name = "AVM_RESOURCE_PROVIDER_NAMESPACE"
            required = $true
            requiredFor = @("resource")
        },
        @{
            key = "resourceType"
            name = "AVM_RESOURCE_TYPE"
            required = $true
            requiredFor = @("resource")
        },
        @{
            key = "moduleDisplayName"
            name = "AVM_MODULE_DISPLAY_NAME"
            required = $true
            requiredFor = @("resource", "pattern", "utility")
        },
        @{
            key = "alternativeNames"
            name = "AVM_MODULE_ALTERNATIVE_NAMES"
            required = $false
        },
        @{
            key = "comments"
            name = "AVM_COMMENTS"
            required = $false
        },
        @{
            key = "primaryOwnerHandle"
            name = "AVM_OWNER_PRIMARY_GITHUB_HANDLE"
            required = $true
            requiredFor = @("resource", "pattern", "utility")
        },
        @{
            key = "primaryOwnerDisplayName"
            name = "AVM_OWNER_PRIMARY_DISPLAY_NAME"
            required = $true
            requiredFor = @("resource", "pattern", "utility")
        },
        @{
            key = "secondaryOwnerHandle"
            name = "AVM_OWNER_SECONDARY_GITHUB_HANDLE"
            required = $false
        },
        @{
            key = "secondaryOwnerDisplayName"
            name = "AVM_OWNER_SECONDARY_DISPLAY_NAME"
            required = $false
        }
    )

    $metaData = $(gh api "/repos/$orgAndRepoName/actions/variables?per_page=30" 2> $null) | ConvertFrom-Json
    $metaDataObject = @{}

    if($metaData.status -and $metaData.status -ne 200) {
        $warning = @{
            repoId = $repository.repoId
            message = "Meta data not found for: $($orgAndRepoName)"
        }
        Write-Warning $warning.message
        $warnings += $warning
    } else {
        Write-Host "Meta data found for: $($orgAndRepoName)"

        foreach($item in $metaDataVariables) {
            $metaDataItem = $metaData.variables | Where-Object { $_.name -eq $item.name }
            if($metaDataItem -and $metaDataItem.value) {
                $metaDataObject.Add($item.key, $metaDataItem.value)
                continue
            } 
            
            $metaDataObject.Add($item.key, "")

            if($item.required -and $item.requiredFor -contains $repository.repoSubType) {
                $warning = @{
                    repoId = $repository.repoId
                    message = "Required meta data $($item.name) not found for: $($orgAndRepoName)"
                }
                Write-Warning $warning.message
                $warnings += $warning
            }
        }
    }

    # Lookup Terraform Registry Status
    $url = "https://registry.terraform.io/v1/modules/$orgName/$repoId/$providerName"
    $response = Invoke-RestMethod $url -StatusCodeVariable statusCode -SkipHttpErrorCheck

    $terraformRegistryPublished = $false
    $terraformRegistryLatestVersion = ""
    $terraformRegistryModuleOwner = ""
    $terraformRegistryFirstPublishedDate = ""

    if($response.errors -and $response.errors -contains "Not Found") {
        Write-Host "Module not found in Terraform Registry: $url"
    } else {
        $terraformRegistryPublished = $true
        $terraformRegistryLatestVersion = $response.version
        $terraformRegistryModuleOwner = $response.owner

        Write-Host "Module found in Terraform Registry. Latest version: $terraformRegistryLatestVersion. Owner: $terraformRegistryModuleOwner"

        $firstVersion = $response.versions[0]
        $firstVersionUrl = "https://registry.terraform.io/v1/modules/$orgName/$repoId/$providerName/$firstVersion"
        $firstVersionResponse = Invoke-RestMethod $firstVersionUrl -StatusCodeVariable statusCode -SkipHttpErrorCheck
        $terraformRegistryFirstPublishedDate = $firstVersionResponse.published_at
    }

    $firstPublishedIn = $terraformRegistryFirstPublishedDate -eq "" ? "" : $terraformRegistryFirstPublishedDate.ToString("yyyy-MM")

    $moduleType = $repository.repoSubType

    $repositoryData += [ordered]@{
        moduleType = $moduleType
        registryFirstPublishedDate = $terraformRegistryFirstPublishedDate
        registryCurrentVersion = $terraformRegistryLatestVersion
        registryModuleOwner = $terraformRegistryModuleOwner
        ProviderNamespace = $metaDataObject.providerNamespace
        ResourceType = $metaDataObject.resourceType
        ModuleDisplayName = $metaDataObject.moduleDisplayName
        AlternativeNames = $metaDataObject.alternativeNames
        ModuleName = $repoId
        ParentModule = "n/a"
        ModuleStatus = $terraformRegistryPublished ? "Available :green_circle:" : "Proposed :new:"
        RepoURL = $repoUrl
        PublicRegistryReference = "https://registry.terraform.io/modules/$orgName/$repoId/$providerName/latest"
        TelemetryIdPrefix = ""
        PrimaryModuleOwnerGHHandle = $metaDataObject.primaryOwnerHandle
        PrimaryModuleOwnerDisplayName = $metaDataObject.primaryOwnerDisplayName
        SecondaryModuleOwnerGHHandle = $metaDataObject.secondaryOwnerHandle
        SecondaryModuleOwnerDisplayName = $metaDataObject.secondaryOwnerDisplayName
        ModuleOwnersGHTeam = $repository.repoOwnerTeam
        ModuleContributorsGHTeam = $repository.repoContributorTeam
        Description = "AVM $moduleType Module for $($metaDataObject.moduleDisplayName)"
        Comments = $metaDataObject.comments
        FirstPublishedIn = $firstPublishedIn
    }
}

$repositoryData | ConvertTo-Json -Depth 10 | Out-File -FilePath "repositoryData.json" -Force -Encoding utf8

$repositoryTypes = @(
    "resource",
    "pattern",
    "utility"
)

$cultureInfo = [System.Globalization.CultureInfo]::CurrentCulture
$textInfo = $cultureInfo.TextInfo

foreach($repositoryType in $repositoryTypes) {
    $filteredRepositoryData = $repositoryData | Where-Object { $_.moduleType -eq $repositoryType }
    foreach($repository in $filteredRepositoryData) {
        $repository.Remove("moduleType")
        $repository.Remove("registryFirstPublishedDate")
        $repository.Remove("registryCurrentVersion")
        $repository.Remove("registryModuleOwner")
    }

    $repositoryTypeTitleCase = $textInfo.ToTitleCase($repositoryType)
    $filteredRepositoryData | Sort-Object { $_.ProviderNamespace, $_.ResourceType } | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath "Terraform$($repositoryTypeTitleCase)Modules.csv" -Force -Encoding utf8
}

if($warnings.Count -eq 0) {
    Write-Host "No issues found"
} else {
    Write-Host "Issues found ($($warnings.Count))"
    $warningsJson = ConvertTo-Json $warnings -Depth 100
    $warningsJson | Out-File "warning.log.json"
}

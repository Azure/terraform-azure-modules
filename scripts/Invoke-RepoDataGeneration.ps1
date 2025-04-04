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
    $providerNamespace = ""
    $resourceType = ""
    $moduleDisplayName = ""
    $alternativeNames = @()
    $comments = ""
    $primaryOwnerHandle = ""
    $primaryOwnerDisplayName = ""
    $secondaryOwnerHandle = ""
    $secondaryOwnerDisplayName = ""

    $metaData = $(gh api "/repos/$orgAndRepoName/actions/variables/avm_meta_data" 2> $null) | ConvertFrom-Json

    if($metaData.status -and $metaData.status -ne 200) {
        $warning = @{
            repoId = $repository.repoId
            message = "Meta data not found for: $($orgAndRepoName)"
        }
        Write-Warning $warning.message
        $warnings += $warning
    } else {
        Write-Host "Meta data found for: $($orgAndRepoName)"

        $metaDataObject = $metaData.value | ConvertFrom-Json

        if($metaDataObject.ProviderNamespace) {
            $providerNamespace = $metaDataObject.ProviderNamespace
        } else {
            $warning = @{
                repoId = $repository.repoId
                message = "ProviderNamespace not found for: $($orgAndRepoName)"
            }
            Write-Warning $warning.message
            $warnings += $warning
        }

        if($metaDataObject.ResourceType) {
            $resourceType = $metaDataObject.ResourceType
        } else {
            $warning = @{
                repoId = $repository.repoId
                message = "ResourceType not found for: $($orgAndRepoName)"
            }
            Write-Warning $warning.message
            $warnings += $warning
        }

        if($metaDataObject.ModuleDisplayName) {
            $moduleDisplayName = $metaDataObject.ModuleDisplayName
        } else {
            $warning = @{
                repoId = $repository.repoId
                message = "ModuleDisplayName not found for: $($orgAndRepoName)"
            }
            Write-Warning $warning.message
            $warnings += $warning
        }

        if($metaDataObject.AlternativeNames) {
            $alternativeNames = @($metaDataObject.AlternativeNames)
        }

        if($metaDataObject.Comments) {
            $comments = $metaDataObject.Comments
        }

        if($metaDataObject.PrimaryOwnerHandle) {
            $primaryOwnerHandle = $metaDataObject.PrimaryOwnerHandle
        } else {
            $warning = @{
                repoId = $repository.repoId
                message = "PrimaryOwnerHandle not found for: $($orgAndRepoName)"
            }
            Write-Warning $warning.message
            $warnings += $warning
        }

        if($metaDataObject.PrimaryOwnerDisplayName) {
            $primaryOwnerDisplayName = $metaDataObject.PrimaryOwnerDisplayName
        } else {
            $warning = @{
                repoId = $repository.repoId
                message = "PrimaryOwnerDisplayName not found for: $($orgAndRepoName)"
            }
            Write-Warning $warning.message
            $warnings += $warning
        }

        if($metaDataObject.SecondaryOwnerHandle) {
            $secondaryOwnerHandle = $metaDataObject.SecondaryOwnerHandle
        }

        if($metaDataObject.SecondaryOwnerDisplayName) {
            $secondaryOwnerDisplayName = $metaDataObject.SecondaryOwnerDisplayName
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
        ProviderNamespace = $providerNamespace
        ResourceType = $resourceType
        ModuleDisplayName = $moduleDisplayName
        AlternativeNames = $alternativeNames -join ", "
        ModuleName = $repoId
        ParentModule = "n/a"
        ModuleStatus = $terraformRegistryPublished ? "Available :green_circle:" : "Proposed :new:"
        RepoURL = $repoUrl
        PublicRegistryReference = "https://registry.terraform.io/modules/$orgName/$repoId/$providerName/latest"
        TelemetryIdPrefix = ""
        PrimaryModuleOwnerGHHandle = $primaryOwnerHandle
        PrimaryModuleOwnerDisplayName = $primaryOwnerDisplayName
        SecondaryModuleOwnerGHHandle = $secondaryOwnerHandle
        SecondaryModuleOwnerDisplayName = $secondaryOwnerDisplayName
        ModuleOwnersGHTeam = $repository.repoOwnerTeam
        ModuleContributorsGHTeam = $repository.repoContributorTeam
        Description = "AVM $moduleType Module for $moduleDisplayName"
        Comments = $comments
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
    Write-Host "Issues found for"
    $warningsJson = ConvertTo-Json $warnings -Depth 100
    $warningsJson | Out-File "warning.log.json"
}

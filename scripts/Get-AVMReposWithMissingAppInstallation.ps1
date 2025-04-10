param(
  $client_id, # This is the Client ID of the GitHub App
  $private_key_path = "azure-verified-modules.pem" # This is the path to the private key for the GitHub App
)

# Authenticate with GitHub CLI using the GitHub App
./scripts/Connect-AsApp.ps1 -client_id $client_id -private_key_path $private_key_path

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

$finalInstalledRepositories = $installedRepositories.name | Sort-Object -Unique

# Get the list of all AVM repositories in the Azure organization
$allRepositories = @()

$searchUris = @(
  "https://api.github.com/search/repositories?q=org:Azure+avm%20in:name",
  "https://api.github.com/search/repositories?q=org:Azure+`"Azure%20Verified%20Modules`"%20in:description",
  "https://api.github.com/search/repositories?q=org:Azure+`"Azure%20Verified%20Modules`"%20in:readme"
)

foreach ($uri in $searchUris) {
  $page = 1
  $incompleteResults = $true

  # Get the paged results 
  while($incompleteResults) {
    $response = ConvertFrom-Json $(gh api "$uri+archived:false&per_page=$itemsPerPage&page=$page")
    $allRepositories += $response.items
    $incompleteResults = $page * $itemsPerPage -lt $response.total_count
    $page++
  }
}

$finalResults = $allRepositories.name | Sort-Object -Unique

# Find the missing repositories
$missingRepos = @()

foreach ($repo in $finalResults) {
  if ($finalInstalledRepositories -notcontains $repo) {
    $missingRepos += $repo
  }
}

Write-Output "Missing Repos:"
foreach($missingRepo in $missingRepos) {
  Write-Output "- $missingRepo"
}

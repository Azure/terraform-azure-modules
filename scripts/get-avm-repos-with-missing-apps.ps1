param(
  $client_id, # This is the Client ID of the GitHub App
  $private_key_path = "azure-verified-modules.pem" # This is the path to the private key for the GitHub App
)

# Get the JWT for the GitHub App
$header = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject @{
  alg = "RS256"
  typ = "JWT"
}))).TrimEnd('=').Replace('+', '-').Replace('/', '_');

$payload = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -InputObject @{
  iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-10).ToUnixTimeSeconds()
  exp = [System.DateTimeOffset]::UtcNow.AddMinutes(10).ToUnixTimeSeconds()
   iss = $client_id
}))).TrimEnd('=').Replace('+', '-').Replace('/', '_');

$rsa = [System.Security.Cryptography.RSA]::Create()
$rsa.ImportFromPem((Get-Content $private_key_path -Raw))

$signature = [Convert]::ToBase64String($rsa.SignData([System.Text.Encoding]::UTF8.GetBytes("$header.$payload"), [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)).TrimEnd('=').Replace('+', '-').Replace('/', '_')
$jwt = "$header.$payload.$signature"

# Set the shared auth headers for the GitHub API
$headers = @{
  "Accept" = "application/vnd.github+json"
  "Authorization" = "Bearer $jwt"
  "X-GitHub-Api-Version" = "2022-11-28"
}

# Get the installation ID for the GitHub App and the Access Token
$installation = Invoke-RestMethod -Uri "https://api.github.com/orgs/Azure/installation" -Headers $headers -Method Get
$accessToken = Invoke-RestMethod -Uri "https://api.github.com/app/installations/$($installation.id)/access_tokens" -Headers $headers -Method Post
$env:GH_TOKEN = $accessToken.token

# Authenticate with GitHub CLI
gh auth login -h "GitHub.com"


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

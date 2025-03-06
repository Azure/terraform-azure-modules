param (
  [string]$moduleProvider = "azurerm",
  [string]$moduleName,
  [string]$moduleDescription,
  [string]$moduleOwner
)

$moduleNameRegex = "^avm-(res|ptn|utl)-[a-z-]+$"

if($moduleName -notmatch $moduleNameRegex) {
  Write-Error "Module name must be in the format '$moduleNameRegex'" -Category InvalidArgument
  return
}

$repositoryName = "terraform-$moduleProvider-$moduleName"

Write-Host "Creating repository $moduleName"

gh repo create "Azure/$repositoryName" --public --template "Azure/terraform-azurerm-avm-template"

Write-Host "Created repository $moduleName"
Write-Host "Open https://repos.opensource.microsoft.com/orgs/Azure/repos/$repositoryName"
Write-Host "Click 'Complete Setup' to finish the repository configuration"
Write-Host "Elevate your permissions with JIT and then come back here to continue"
$response = ""
while($response -ne "yes") {
  $response = Read-Host "Type 'yes' Enter to continue..."
}

$tfvars = @{
  module_provider = $moduleProvider
  module_id = $moduleName
  module_name = $moduleDescription
  module_owner_github_handle = $moduleOwner
}

$tfvars | ConvertTo-Json | Out-File -FilePath "terraform.tfvars.json" -Force

if(Test-Path "terraform.tfstate") {
  Remove-Item "terraform.tfstate" -Force
}
if(Test-Path ".terraform") {
  Remove-Item ".terraform" -Force -Recurse
}
if(Test-Path ".terraform.lock.hcl") {
  Remove-Item ".terraform.lock.hcl" -Force
}

terraform init
terraform apply -auto-approve

# Azure Terraform Verified Modules

> This repo contains the source code of all currently available Terraform modules verified by Microsoft Azure. All verified modules will meet the quality pipeline established by Microsoft Azure team, which guarantee their high quality.    

## Modules
Below is a table containing all Terraform modules verified by Microsoft Azure. Each module version badge shows the latest version of the corresponding module. You may click on a version badge to check all available versions for a specific module. Each minimum Terraform version shows the minimum entry requirements for the version of Terraform. Using the verified modules below the required Terraform version might cause potential inconsistency and disruption. 
> For those with parallel modules, we strongly recommend you transfer your existing infrastructure to the new verified modules, as old parallel modules will no longer be updated. 

<!-- Begin Module Table -->

| Module            | Module Version | Minimum Terraform Version | Docs                                                 |Key Metrics                                                 | Version Details|
| ----------        | :-----------:  | :-----------:             |----------                                            | :-----------:                                             |:-----------:   |
| Terraform-AzureRM | 1.2.0          | 1.13.0                    |https://github.com/Azure/terraform-azurerm-subnets    | daily downloads     weekly downloads  yearly downloads    |docs            |



## Contributing

We only accept contributions from Microsoft employees at this time. Teams within Microsoft can refer to Contributing to Terraform Verified Modules Registry for more information. External customers can propose new modules or report bugs by opening an issue.  

### Prerequisite
https://github.com/apps/1es-resource-management/ Install the 1ES (One Engineering Service) Resource Management GitHub APP 

### Creating a new verified module
#### Making a pull request
When creating a new module in alignment with our verified module pipeline, you should make a pull request. Each module needs to have its own pull request. The pull request shall integrate the following content:  
1. Has your module already existed in the Terraform-Azure-registry?
2. Module Path (Please provide the GitHub Repository of your module. You should guarantee that your repository looks the same as this template created by Zijie: https://github.com/lonegunmanb/terraform-verified-module 
3. Describe your module (A clear and concise description of your module would be strongly preferred)

#### CI/CD Pipeline Deployment 
Run make pre-commit to check the Terraform code in local environment

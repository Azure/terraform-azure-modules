# Azure Terraform Verified Modules

This GitHub repository contains essential information related to Azure Terraform verified modules, including a brief introduction of modules, the verified module list, and how Terraform practitioners contribute to verified modules. Please note that all the verified modules meet the quality pipeline established by the Microsoft Azure team. 

## What is Terraform Module
Terraform modules encapsulate groups of resources dedicated to one task, reducing the code you have to develop for similar infrastructure components. A typical module might contain a set of configuration files in one single directory, and integrate the following items: main.tf, variables.tf, output.tf, and README.md.

## Verified Modules Table
Below is a table containing all Terraform modules verified by Microsoft Azure. Here is a detailed explanation of the column header for your notification: 

The `Module Version` badge shows the latest version of the corresponding module, and you may click on it to check the core functions and changes in each version of the module. 

The `Minimum Terraform Version` shows the minimum version requirement for Terraform when calling the verified module. Using the verified module below the required Terraform version might cause potential inconsistency and disruption. For instance, when it displays 1.13.0, we suggest you use a Terraform version greater than v1.13.0.

In the `Docs` section, you can click on the `README.md` file to learn the contained resources of the verified modules, how to CRUD the verified modules in your environment, as well as the key input and output of verified modules. 

The `Total Downloads` calculate the downloads of the specific verified module over time, indicating its popularity among Terraform practitioners. 


<!-- Begin Module Table -->

| Module                    | Module Version                                              | Minimum Terraform Version | Docs                                                                                                                  |Total Downloads|
| ----------                | :-----------:                                               | :-----------:             |----------                                                                                                            | :-----------: |
| Terraform-AzureRM-Subnets | [1.0.0](https://github.com/Azure/terraform-azurerm-subnets) | 1.13.0                    |[README.md](https://github.com/Azure/terraform-azurerm-subnets/blob/master/README.md)    | 11,300        |



## Contributing

We only accept contributions from Microsoft employees at this time. Teams within Microsoft can refer to [Contributing to Terraform Verified Modules Registry](https://github.com/Jingwei-MS/terraform-azure-modules/blob/main/Contribute.md) for more information. 

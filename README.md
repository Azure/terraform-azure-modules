# Azure Terraform Verified Modules

## ⚠️ Notice

This program is merging with [Azure Verified Modules](https://aka.ms/avm) to provide a consistent user experience across IaC languages on Azure.
***Existing TFVM modules will continue to be supported***, but for new projects you are advised to check the AVM [available modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/) and use those if available.
New modules will be created under the branding of AVM, so please check the website for more information.

## Background

This GitHub repository contains essential information related to Azure Terraform verified modules, including a brief introduction of modules, the documentation for verified modules and pointers to the module repos, and how Terraform practitioners can contribute to verified modules. Please note that all the verified modules meet the quality pipeline established by the Microsoft Azure team. 

## What is Terraform Module
Terraform modules encapsulate groups of resources dedicated to one task, reducing the code you have to develop for similar infrastructure components. A typical module will contain a set of configuration files in one single directory, and integrate the following items: main.tf, variables.tf, output.tf, test folder, and README.md.

## Verified Modules Table
Below is a table containing all Terraform modules verified by Microsoft Azure. Here is a detailed explanation of the items for your notification: 

The `Module Version` badge shows the latest version of the corresponding module, and you may click on it to check the core functions and changes in each version of the module. 

The `Minimum Terraform Version` shows the minimum version requirement for Terraform when calling the verified module. Using the verified module below the required Terraform version might cause potential inconsistency and disruption. For instance, when it displays 1.13.0, we suggest you use a Terraform version greater than v1.13.0.

In the `Docs` section, you can click on the `README.md` file to learn the contained resources of the verified modules, how to CRUD the verified modules in your environment, as well as the key input and output of verified modules. 

The `Total Downloads` calculate the downloads of the specific verified module over time, indicating its popularity among Terraform practitioners. 


<!-- Begin Module Table -->

| Module                    | Module Version                                              | Minimum Terraform Version | Docs                                                                                                                  |Total Downloads|
| ----------                | :-----------:                                               | :-----------:             |----------                                                                                                            | :-----------: |
| terraform-azurerm-aks | [7.3.0](https://github.com/Azure/terraform-azurerm-aks) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-aks/blob/master/README.md) | xxxx |
| terraform-azurerm-compute | [5.3.0](https://github.com/Azure/terraform-azurerm-compute) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-compute/blob/master/README.md) | xxxx |
| terraform-azurerm-loadbalancer | [4.4.0](https://github.com/Azure/terraform-azurerm-loadbalancer) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-loadbalancer/blob/master/README.md) | xxxx |
| terraform-azurerm-network | [5.3.0](https://github.com/Azure/terraform-azurerm-network) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-network/blob/master/README.md) | xxxx |
| terraform-azurerm-network-security-group | [4.1.0](https://github.com/Azure/terraform-azurerm-network-security-group) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-network-security-group/blob/master/README.md) | xxxx |
| terraform-azurerm-postgresql | [3.1.1](https://github.com/Azure/terraform-azurerm-postgresql) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-postgresql/blob/master/README.md) | xxxx |
| terraform-azurerm-subnets | [1.0.0](https://github.com/Azure/terraform-azurerm-subnets) | 1.2.0 |[README.md](https://github.com/Azure/terraform-azurerm-subnets/blob/master/README.md) | xxxx |
| terraform-azurerm-virtual-machine | [1.0.0](https://github.com/Azure/terraform-azurerm-virtual-machine) | 1.2.0 | [README.md](https://github.com/Azure/terraform-azurerm-virtual-machine/blob/main/README.md) | xxxx |

## Contributing

We accept contributions from not only Microsoft employees but the broader developer community. If you want to make contributions, please refer to [Contributing to Terraform Verified Modules Registry](https://github.com/Jingwei-MS/terraform-azure-modules/blob/main/Contribute.md) for more information. 

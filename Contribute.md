# Contributing to Terraform Verified Modules  
We accept pull requests created by not only Microsoft employees but the wider developer community. The following instructions will help you with the development of Azure Terraform verified modules. Please follow it step by step. 

## Creating a New Verified Module
### Create Your own GitHub Repository of Your Module
Please guarantee that your repository looks exactly the same as this [template](https://github.com/lonegunmanb/terraform-verified-module) created by Zijie. The repo shall normally contain the following items: 

`LICENSE` will contain the license under which your module will be distributed. When you share your module, the LICENSE file will let people using it know the terms under which it has been made available.

`README.md` will contain documentation describing how to use your module, in markdown format. A clear and concise description of your module would be strongly preferred. 

`main.tf` will contain the main set of configuration for your module. You can also create other configuration files and organize them however makes sense for your project.

`variables.tf` will contain the variable definitions for your module. Since all Terraform values must be defined, any variables that are not given a default value will become required arguments. Variables with default values can also be provided as module arguments, overriding the default value.

`outputs.tf` will contain the output definitions for your module. 

`examples` will contain real-world examples of using your module. Please make sure that they are up-dated, functional, and easy to understand. 

`test` folder will normally contain functional test files covering e2e test, unit test, and upgrade test. 

### Tests before Commit

1. First, you should set up service principal’s credentials in your environment variables like below: 

```
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"

export ARM_TENANT_ID="<azure_subscription_tenant_id>"

export ARM_CLIENT_ID="<service_principal_appid>"

export ARM_CLIENT_SECRET="<service_principal_password>"
```
2. Second, we recommend you run the pre-commit checks and tests in our provided docker image. In order to do this, you need to download [docker](https://www.docker.com/pricing/#/download), then run the command via your terminal: `mcr.microsoft.com/azterraform:latest`.

3. Third, please run `make pre-commit` to check the Terraform code in your local environment. For Mac/Linux, the whole command should be like this: `$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit`; for Windows, the whole command should be like this: `$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit` We have integrated the following steps in the single `make pre-commit` command: 

```
  Run `terraform fmt -recursive` command for your Terraform code.

  Run `terrafmt fmt -f` command for markdown files and go code files to ensure that the Terraform code embedded in these files are well formatted.

  Run `go mod tidy` and `go mod vendor` for test folder to ensure that all the dependencies have been synced.

  Run `gofmt` for all go code files.

  Run `gofumpt` for all go code files.

  Run `terraform-docs` on README.md file, then run `markdown-table-formatter` to format markdown tables in README.md.
```

4. Forth, please run the `pr-check` task to check whether our code meets our pipeline’s requirement. For Mac/Linux, the whole command should be like this: `$ docker run --rm -v $(pwd):/src -w /src mcr.microsoft.com/azterraform:latest make pr-check`; for Windows, the whole command should be like this: `$ docker run --rm -v ${pwd}:/src -w /src mcr.microsoft.com/azterraform:latest make pre-commit`

5. Finally, please run the `e2e-test` with the following command. For Mac/Linux, the whole command should be like this: `docker run --rm -v $(pwd):/src -w /src -e ARM_SUBSCRIPTION_ID -e`; for Windows, the whole command should be like this: `docker run --rm -v ${pwd}:/src -w /src -e ARM_SUBSCRIPTION_ID -e ARM_TENANT_ID -e ARM_CLIENT_ID -e ARM_CLIENT_SECRET mcr.microsoft.com/azterraform:latest make e2e-test`

6. Finally, install the 1ES ([One Engineering Service](https://github.com/apps/1es-resource-management/installations/24223778)) to enable the subsequent automatic tests. 

### Make a Pull Request
After passing all the pre-commit & pr-check & E2E test, you can make a pull request in our [repo](https://github.com/Azure/terraform-azure-modules). Please note that each module needs to have its own pull request. 

Subsequently, our CI pr-check will be executed automatically. Once the pr-check has passed, the e2e test and version upgrade test will be executed with manual approval. Passing all tests indicates that your modules are in alignment with our verified module pipeline. If the tests fail, please refer to the pipeline's output and make modifications. Thank you for your cooperation. 

### The End
When your pull request has been merged into our main branch, as the module owner, you are responsible for maintaining and updating it. In cases that you are not able to guarantee its applicability in real business scenarios, please inform the Azure Terraform team as soon as possible. We will alert users the potential risk or roll it off from our GitHub repo. 

Thank you for your attention and hope you enjoy the whole process!
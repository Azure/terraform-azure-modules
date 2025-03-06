# Azure Verified Modules - Repository Creation Steps

1. Login to GitHub CLI: `gh auth login -h "github.com" -w -p "https" -s "delete_repo" -s "workflow" -s "read:user" -s "user:email"`
2. Follow the prompts to login to your GitHub account.
3. Run the following PowerShell command to create a new repository:

    ```pwsh
    $moduleProvider = "azurerm"
    $moduleName = "avm-res-example-test" # Replace with the module name (do not include the "terraform-azurerm" prefix)
    $moduleDescription = "Resource Module for Testing Purposes" # Replace with a short description of the module
    $moduleOwner = "github-username" # Replace with the GitHub handle of the module owner

    ./New-Repository.ps1 `
        -moduleProvider $moduleProvider `
        -moduleName $moduleName `
        -moduleDescription $moduleDescription `
        -moduleOwner $moduleOwner

    ```

3. The script will stop and prompt you to fill out the Microsodtf Open Source details that can be found here: https://dev.azure.com/CSUSolEng/Azure%20Verified%20Modules/_wiki/wikis/AVM%20Internal%20Wiki/333/-TF-Create-repository-in-Github-Azure-org-and-conduct-business-review?anchor=conduct-initial-repo-configuration-and-trigger-business-review
4. Once you have completed the details. Refresh the open source portal and elevate your permissions with JIT
5. Now head back to the console, then type `yes` and hit enter to complete the repository configuration
6. Request `Azure Verified Modules` GitHub App installation using this link: https://github.com/microsoft/github-operations/issues/new/choose
7. Once the GitHub App is installed, the rest of the repository setup will continue automatically within 4 hours
8. Send an email or Teams message to the module owner to let them know the repository has been created
9. Remove the `Status: Ready For Repository Creation` label from the [Issue](https://github.com/Azure/Azure-Verified-Modules/issues)
10. Add the `Status: Repository Created` label to the [Issue](https://github.com/Azure/Azure-Verified-Modules/issues)

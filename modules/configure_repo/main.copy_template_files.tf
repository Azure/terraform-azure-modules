locals {
    repo_name = "terraform-azurerm-${var.name}"
    path_list = [ for value in jsondecode(data.github_rest_api.tree.body).tree : value.path ]
}

#get the full template repo tree
data "github_rest_api" "tree" {
  endpoint = "repos/Azure/${var.template_repo_name}/git/trees/main?recursive=true"
}

#read the templates file details
data "github_repository_file" "read" {
    for_each = toset(local.path_list)
    
    repository = "Azure/${var.template_repo_name}"
    file = each.value
}

#create a branch to copy the files into
resource "github_branch" "template_copy" {
  repository = local.repo_name
  branch = var.template_copy_branch_name
}

#write the files to the branch
resource "github_repository_file" "write" {
    for_each = {for key, value in data.github_repository_file.read : key => value if try(value.content, null) != null}

    repository = local.repo_name
    file = each.value.file
    content = data.github_repository_file.read[each.value.file].content
    overwrite_on_create = true
    branch = github_branch.template_copy.branch
}

#create a PR for the branch
resource "github_repository_pull_request" "this" {
    base_repository = local.repo_name
    base_ref        = "main"
    head_ref        = github_branch.template_copy.branch
    title           = "Template File update"
    body            = "This PR copies the AVM template files into the new repo"
    maintainer_can_modify = false

    depends_on = [ github_repository_file.write, github_branch.template_copy ]
}

#merge the PR - No provider option to take this action, can we do this with the API?

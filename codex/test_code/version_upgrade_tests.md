# Version upgrade tests

To avoid breaking changes after a minor version upgrade, we need a version upgrade test.

The logics of version upgrade tests are implemented in E2E test helper: [github.com/Azure/terraform-module-test-helper](https://github.com/Azure/terraform-module-test-helper).

Firstly it will get the latest version number through GitHub API, then a copy of the latest module code will be checked out under `/tmp/`. After that Terratest will be executed in every subdirectory under `examples`, change the `source` of `module` which has a path like `../..` or `../../`, pointing it to the directory in the main branch after merging the current PR. Then re-execute `terraform init` and `terraform plan` to see of there are changes. If the changes exist, that means the upgrade contains an "accident" breaking change.

Ideally, users won't see any changes in minor version upgrade if they don't modify input `variable`s. The version upgrade test would be skipped if the next release would be a major version upgrade.
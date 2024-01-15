# Version Upgrade Tests

To ensure that minor version upgrades do not introduce breaking changes, we perform version upgrade tests.

The logic for these tests is implemented in the End-to-End (E2E) test helper, located at [github.com/Azure/terraform-module-test-helper](https://github.com/Azure/terraform-module-test-helper).

The process for these tests is as follows:

1. Retrieve the latest version number of the module using the GitHub API.
2. Check out a copy of the latest module code into the `/tmp/` directory.
3. Run Terratest, a tool for testing infrastructure code, on each subdirectory under the `examples` directory.
4. If the source of the module in the example configurations is a relative path (like `../..` or `../../`), update it to point to the directory in the main branch that will exist after the current Pull Request (PR) is merged.
5. Run `terraform init` and `terraform plan` again to check for any changes.
6. If there are changes, this indicates that the upgrade unintentionally introduced a breaking change.

In an ideal scenario, users should not see any changes when upgrading minor versions, unless they modify input variables. If the next release is a major version upgrade, the version upgrade test is skipped.

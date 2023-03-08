# E2E test

An end-to-end test is used to ensure the sample code works properly. Every sample code folder should have a corresponding E2E test under `test/e2e/` directory.

## Composing E2E tests

There is a helper function for composing E2E tests: [github.com/Azure/terraform-module-test-helper](https://github.com/Azure/terraform-module-test-helper), this function encapsulates a standard logic for running E2E tests, it will return an output for verification use.

E2E test will take the root path of the module and relative path for the example, then execute `terraform apply` to the example. If everything goes well, it will execute `terraform plan` and confirm there's no drift by analyzing the output of it. After that it will execute `terraform plan -json` and pass the output value to our callback function for verification. If there's no exception found, the function will run `terraform destroy` to destroy all resources created.

There will be accidental errors pop up now and then for some reason, usually they will disappear right after a quick rerun. We can always write a [Terragrunt formatted `retryable_errors` configuration file](https://terragrunt.gruntwork.io/docs/features/auto-retry/) to pass the errors to the test framework, then it will trigger an automatic rerun if we encounter some specific errors.
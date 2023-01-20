# (Optional) Unit tests

Unit tests are mainly for some complicated logics in Terraform code. We can extract the expressions containing complicated logics to `local` blocks, and perform tests against `local` expressions. Unit tests are optional, if they are composed please put the test code in `test/unit` directory.

Specifically, create a symlink in `unit-test-fixture` directory pointing to `variable.tf` and `locals.tf`, then `unit-test-fixture` will be a Terraform module which contains only `variable` and `locals` block. Unit tests can be created for this module.

Make sure that unit tests does not involve any `resource` or `data` related to outside services. To verify the test results, an independent `outputs.tf` file can be added to the unit test folder to hold the outputs of the expressions in `local` need to be verified. `resource` and `data` that does not depend on outside services like `null_resource`, `random_id` can also be used.

To ensure that the sysmlink works fine on Windows, please ensure that you've applied one of the following configuration commands before you clone the repo on Windows:

1. Global setting: `git config --global core.symlinks true`
2. Local setting: `git config core.symlinks true`
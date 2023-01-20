# Logical code of a Module

<!-- TODO: Link will be provided after the release of Terraform Style Guide -->
All `.tf` code should follow [Terraform Style Guide]() first.

Module logical code consists of the following parts:

* A set of input - `variables.tf`
* A set of output - `outputs.tf`
* All expressions independent from `resource` and `data`, containing calculations and logics, are defined as `local` in `locals.tf`
* `versions.tf` file containing `terraform` blocks
* Files containing resource definitions
* (Optional) `deprecated-variables.tf` and `deprecated-outputs.tf` file containing deprecated input/output parameters
* Other files

## Why an independent `locals.tf` file is required?

For some expressions containing calculations and logics independent from `resource` and `data`, the logics within could be extremely complicated. We can compose some unit tests for them, this kind of unit tests will refer to `locals.tf` file under test directory through symlinks. We will introduce this in details in testing chapter.
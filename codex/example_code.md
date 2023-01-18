# Rules for example code

Every module should contain an `examples` folder.

Every `examples` folder should contain at least one sub folder(the suggested names are `startup` or `complete`), it will contain the most commonly seen use case(some `variable`s are mutex, so it could be impossible to use all of them at the same time).

Some other folders containing example code are also welcomed. The name should reflect the use case. For example in AKS module, a folder called `aci` demonstrated how to create an AKS cluster with `aci` enabled.

## Configuration of `prevent_deletion_if_contains_resources` in `provider` block

From Terraform AzureRM 3.0, the default value of `prevent_deletion_if_contains_resources` in `provider` block is `true`. This will lead to an unstable test(because the test subscription has some policies applied and they will add some extra resources during the run, which can cause failures during destroy of resource groups).

Please explicitly set `prevent_deletion_if_contains_resources` to `false`.

## Demo code should be runnable

Demo code can have some `variable`s with `default` value configured or have corresponding `terraform.tfvars` file created, which enables the user to run `terraform apply` directly.
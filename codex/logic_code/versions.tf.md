# `versions.tf` Rules

`versions.tf` file can only contain one `terraform` block.

The first line of this `terraform` block should define like: `required_version = ">= 1.1"`.

`terraform` block should contain a block called `required_providers`, the content of it is the restrictions for provider's version. Provider's version restriction should be sorted in alphabetical order, same for the assignment statements. `version` restrctions should use `>=` if not specified. No other kinds of restrictions can be used without proper justification.

All the providers used in the module should be defined in `required_providers`.

Since a major version upgrade of the provider can lead to a breaking change, a major version upgrade of the provider must come with a major version upgrade of the module itself. Which means, we should almost always declare `azurerm` block like the following example:

```terraform
azurerm = {
  source  = "hashicorp/azurerm"
  version = ">= 3.11, < 4.0"
}
```

## Declaration of a provider in the module

[By rules](https://www.terraform.io/docs/language/modules/develop/providers.html), in the module code `provider` cannot be declared. The only exception is when the module indeed need different instances of the same kind of `provider`(Eg. manipulating resources across different `location`s or accounts), a `provider` block is allowed under `terraform` block in `versions.tf` file, and use `configuration_aliases` to associate them in `terraform.required_providers`. See details in this [document](https://www.terraform.io/docs/language/providers/configuration.html#alias-multiple-provider-configurations).

`provider` block declared in the module can only be used to differentiate instances used in  `resource` and `data`. Declaration of fields other than `alias` in `provider` block is strictly forbidden. It could lead to module users unable to utilize `count`, `for_each` or `depends_on`. Configurations of the `provider` instance should be passed in by the module users.
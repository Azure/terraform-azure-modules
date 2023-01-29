# Rules for Files Containing Resource Definitions

Resource declaration code should be placed together by its domain. If the number of resources defined in a module is not large, or the types are highly cohesive (Eg. there are multiple resources belong to the same domain), they can be defined in the same `main.tf` file. If it involves resources from multiple different domains, they should be placed in files which can represent their types. Eg. `virtual_machines.tf`, `network.tf`, `storage.tf` etc. The core scope of a module should be defined in `main.tf`.

## What kind of `resource` should be declared in a module

Let's say we have a module named `terraform-azurerm-vm`, which can create virtual machine related resources.

The criterion for determining whether a `resource` should be put into the current module is: only the `resource` that "belongs" to this module should be declared.

e.g.: an `azurerm_linux_virtual_machine` could be declared along with an `azurerm_dedicated_host_group`, but obviously, an `azurerm_dedicated_host_group` won't be exclusive to a virtual machine, so there **should not** be `azurerm_dedicated_host_group` in `terraform-azurerm-vm` module.

## The Order of `resource` and `data` in the Same File

For the definition of resources in the same file, the resources be depended on come first, after them are the resources depending on others.

Resources have dependencies should be defined close to each other.

## The Definition of `local`s Depending on `resource` or `data` Attributes

For some duplicated or complicated expressions, to increase readability, we encourage authors to extract them out and referenced as independent `local`s.

If the expression involves `resource` or `data`, the `local` should be defined right below the most important definition block of the related `resource` or `data`. Under the same `resource` or `data` block, at most one `local` block can exist, all the `local`s defined here should be ranked in alphabetical order. No blank lines between 2 `local`s.

## The Use of `count` and `for_each`

We can use `count` and `for_each` to deploy multiple resources, but the improper use of `count` can lead to [unpredictable behaviors](https://github.com/lonegunmanb/unpredictable_tf_behavior_sample).

`count` can be used only when creating a set of identical or almost identical resources. For example, if we use `count` to iterate through a `list(string)`, there is a great chance that it could be wrong because modifying the elements in the list will lead to a change of resources order, thus causing unpredictable issues.

Another way of using `count` is to create some kind of resources under certain conditions, for example:

```terraform
resource "azurerm_network_security_group" "this" {
  count               = local.create_new_security_group ? 1 : 0
  name                = coalesce(var.new_network_security_group_name, "${var.subnet_name}-nsg")
  resource_group_name = var.resource_group_name
  location            = local.location
  tags                = var.new_network_security_group_tags
}
```

## Orders Within `resource` and `data` Blocks

There are 3 types of assignment statements in a `resource` or `data` block: argument, meta-argument and nested block. The argument assignment statement is a parameter followed by `=`:

```terraform
location = azurerm_resource_group.example.location
```

or:

```terraform
tags = {
  environment = "Production"
}
```

Nested block is a assignment statement of parameter followed by `{}` block:

```terraform
subnet {
  name           = "subnet1"
  address_prefix = "10.0.1.0/24"
}
```

Meta-arguments are assignment statements can be declared by all `resource` or `data` blocks. They are:

* `count`
* `depends_on`
* `for_each`
* `lifecycle`
* `provider`

The order of declarations within `resource` or `data` blocks is:

All the meta-arguments should be declared on the top of `resource` or `data` blocks in the following order:

1. `provider`
2. `count`
3. `for_each`

Then followed by:

1. required arguments
2. optional arguments
3. required nested blocks
4. optional nested blocks

All ranked in alphabetical order.

These meta-arguments should be declared at the bottom of a `resource` block with the following order:

1. `depends_on`
2. `lifecycle`

The parameters of `lifecycle` block should show up in the following order:

1. `create_before_destroy`
2. `ignore_changes`
3. `prevent_destroy`

parameters under `depends_on` and `ignore_changes` are ranked in alphabetical order.

Meta-arguments, arguments and nested blocked are separated by blank lines.

`dynamic` nested blocks are ranked by the name comes after `dynamic`, for example:

```terraform
  dynamic "linux_profile" {
    for_each = var.admin_username == null ? [] : ["linux_profile"]

    content {
      admin_username = var.admin_username

      ssh_key {
        key_data = replace(coalesce(var.public_ssh_key, tls_private_key.ssh[0].public_key_openssh), "\n", "")
      }
    }
  }
```

This `dynamic` block will be ranked as a block named `linux_profile`.

Code within a nested block will also be ranked following the rules above.

## Order within a `module` block

The meta-arguments below should be declared on the top of a `module` block with the following order:

1. `source`
2. `version`
3. `count`
4. `for_each`

blank lines will be used to separate them.

After them will be required arguments, optional arguments, all ranked in alphabetical order.

These meta-arguments below should be declared on the bottom of a `resource` block in the following order:

1. `depends_on`
2. `providers`

Arguments and meta-arguments should be separated by blank lines.

## Values in `ignore_changes` passed to `provider`, `depends_on`, `lifecycle` blocks are not allowed to use double quotations

## For resources have configurable `tags` field, `tags` should be always exposed to module users through `variable` to ensure they are able to set `tags`

## Cases where we create some resource based on whether the input parameter is `null`

Sometimes we need to ensure that the resources created compliant to some rules at a minimum extent, for example a `subnet` has to connected to at least one `network_security_group`. The user may pass in a `security_group_id` and ask us to make a connection to an existing `security_group`, or want us to create a new security group.

Intuitively, we will define it like this:

```terraform
variable "security_group_id" {
  type = string
}

resource "azurerm_network_security_group" "this" {
  count               = var.security_group_id == null ? 1 : 0
  name                = coalesce(var.new_network_security_group_name, "${var.subnet_name}-nsg")
  resource_group_name = var.resource_group_name
  location            = local.location
  tags                = var.new_network_security_group_tags
}
```

The disadvantage of this approach is if the user create a security group directly in the root module and use the `id` as a `variable` of the module, the expression which determines the value of `count` will contain an `attribute` from another `resource`, the value of this very `attribute` is "known after apply" at plan stage. Terraform core will not be able to get an exact plan of deployment during the "plan" stage.

For this kind of parameters, wrapping with `object` type is recommended：

```terraform
variable "security_group" {
  type = object({
    id   = string
  })
  default     = null
}
```

The advantage of doing so is encapsulating the value which is "known after apply" in an object, and the `object` itself can be easily found out if it's `null` or not. Since the `id` of a `resource` cannot be `null`, this approach can avoid the situation we are facing in the first example.

Please use this technique under this use case only.

## Optional nested object argument should use `dynamic`

An example from the community:

```terraform
resource "azurerm_kubernetes_cluster" "main" {
  ...
  dynamic "identity" {
    for_each = var.client_id == "" || var.client_secret == "" ? [1] : []

    content {
      type                      = var.identity_type
      user_assigned_identity_id = var.user_assigned_identity_id
    }
  }
  ...
}
```

Please refer to the coding style in the example. If you just want to declare some nested block under conditions, please use:

```terraform
for_each = <condition> ? [<some_item>] : []
```


## Use `coalesce` when setting default values for nullable expressions

The following example shows how to use `"${var.subnet_name}-nsg"` when `var.new_network_security_group_name` is `null` or `""`

```terraform
coalesce(var.new_network_security_group_name, "${var.subnet_name}-nsg")
```

## Use the `try` function flexibly

Let's say we have such resource declaration:

```terraform
resource "azurerm_public_ip" "pip" {
  count = var.create_public_ip ?  : 0
  allocation_method   = "Dynamic"
  location            = local.resource_group.location
  name                = "pip-${random_id.id.hex}"
  resource_group_name = local.resource_group.name
}
```

We can use the `try` function to simplify the code without reading the value of `var.create_public_ip` when we'd like to use `azurerm_public_ip`:

```terraform
ip_configurations = [
  {
    public_ip_address_id = try(azurerm_public_ip.pip[0].id, null)
    primary              = true
  }
]
```
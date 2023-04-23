# Rules for `variable`

## Order to define `variable`

Input variables should follow this order:

1. All required fields, in alphabetical order
2. All optional fields, in alphabetical order

A `variable` with `default` value is a required field, otherwise it's an optional one.

## `variable` follows case law

Ensure that the `name`, `description`, `validation` of `variable` are consistent with `resource`, `data` in the context, while making sure the same `variable` in different modules has the same name.

Prefixes ending with `_` are allowed to differentiate `variable`s. Eg.

```terraform
resource "azurerm_linux_virtual_machine" "webserver" {
  name                = "webserver"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  source_image_id     = var.webserver_source_image_id
  ...
}
```

In this case, in `webserver_source_image_id`, `source_image_id` is aligned with the argument in `resource`, `webserver_` is allowed as a prefix.

Assuming a `variable` is an input parameter used for passing value to a resource, then the name of this `variable` should use the name of the input parameter defined in the resource(prefix is allowed). `description` should copy from the related descriptions in resource definition documents.

## Name of a `variable` should follow rules

The naming of a `variable` should follow [HashiCorp's naming rule](https://www.terraform.io/docs/extend/best-practices/naming.html).

`variable` used as feature switches should use positive statement, use `xxx_enabled` instead of `xxx_disabled`. Avoid double negatives like `!xxx_disabled`.

Please use `xxx_enabled` instead of `xxx_disabled` as name of a `variable`.

## Every `variable` should come with a `description`

The target audience of `description` is the module users.

For a newly created `variable` (Eg. `variable` for switching `dynamic` block on-off), it's `description` should precisely describe the input parameter's purpose and the expected data type. `description` should not contain any information for module developers, this kind of information can only exist in code comments.

For `object` type `variable`, `description` can be composed in HEREDOC format:

```terraform
variable "test_obj" {
  type = object({
    id   = string
    name = string
  })
  default     = null
  description = <<-EOF
  {
    id   = "the id of this object"
    name = "the name of this object"
  }
  EOF
}
```

## Every `variable` must have an appropriate `type`

`type` must be defined for every `variable`. `type` should be as precise as possible, `any` can only be defined with adequate reasons.

* Use `bool` instead of `string` or `number` for `true/false`
* Use `string` for text

## `error_message` of a `variable`'s `validation` should use a full sentence to describe the rules that need to be followed by the expected data

## `variable` containing confidential data should be declared as `sensitive = true`

If `variable`'s `type` is `object` and contains one or more fields that would be assigned to a `sensitive` argument, then this `variable` should be declared as `sensitive = true`.

## Declare `nullable = false` if possible

## Do not declare `nullable = true`

## Do not declare `sensitive = false`

## `variable` with `sensitive = true` cannot have default value unless the default value represents turning off a feature, like `default = null` or `default = []`

## `default` value of a `variable`

Setting the `default` value of a `variable` should follow these rules:

1. Use a certain value with an adequate reason - Eg. this value is specifically designed for the module's use case
2. Use related `resource`'s schema default value. If there's no default value available, `default = null`

Eg. a module allows the user to use `variable` to define network access rules:

```terraform
variable "network_security_rules" {
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    description                  = string
    protocol                     = string
    source_port_ranges           = optional(list(string))
    destination_port_ranges      = optional(list(string))
    source_address_prefixes      = optional(list(string))
    destination_address_prefixes = optional(string)
  }))

  default = [
    {
      name                         = "ssh"
      priority                     = 4096
      access                       = "Deny"
      direction                    = "In"
      description                  = ["no remote connection"]
      protocol                     = "Tcp"
      source_port_ranges           = ["*"]
      destination_port_ranges      = ["22", "3389"]
      source_address_prefixes      = ["*", "**"]
      destination_address_prefixes = ["*"]
    }
  ]
}

resource "azurerm_network_security_rule" "example" {
  for_each                    = toset(var.network_security_rules)
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.example.name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  description                 = try(each.value.description[0], null)
  source_port_ranges          = each.value.source_port_range
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefixes     = each.value.source_address_prefixes
  destination_address_prefix  = try(each.value.destination_address_prefix[0], null)
}
```

Secure `default` values should be provided to the utmost.

## A blank line should exist between 2 `variable`s

## Deal with deprecated `variable`

Sometimes we will find names for some `variable` are not suitable anymore, or a change should be made to the data type. We want to ensure forward compatibility within a major version, so direct changes are strictly forbidden. The right way to do this is move this `variable` to an independent `deprecated_variables.tf` file, then redefine the new parameter in `variable.tf` and make sure it's compatible everywhere else.

Deprecated `variable` must be annotated as `DEPRECATED` at the beginning of the `description`, at the same time the replacement's name should be declared. E.g.

```terraform
variable "enable_network_security_group" {
  type        = string
  default     = null
  description = "DEPRECATED, use `network_security_group_enabled` instead; Whether to generate a network security group and assign it to the subnet. Changing this forces a new resource to be created."
}
```

A cleanup of `deprecated_variables.tf` can be performed during a major version release.
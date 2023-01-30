## Feature toggle should be used to ensure forward compatibility of versions and avoid unexpected changes caused by upgrades

E.g., our previous release was `v1.2.1`, now we'd like to submit a pull request which contains such new `resource`:

```terraform
resource "azurerm_route_table" "this" {
  location            = local.location
  name                = coalesce(var.new_route_table_name, "${var.subnet_name}-rt")
  resource_group_name = var.resource_group_name
}
```

A user who's just upgraded the module's version would be surprised to see a new resource to be created in a newly generated plan file.

A better approach is adding a feature toggle to be turned off by default:

```terraform
variable "create_route_table" {
  type     = bool
  default  = false
  nullable = false
}
resource "azurerm_route_table" "this" {
  count               = var.create_route_table ? 1 : 0
  location            = local.location
  name                = coalesce(var.new_route_table_name, "${var.subnet_name}-rt")
  resource_group_name = var.resource_group_name
}
```

Similarly, when adding a new argument assignment in a `resource` block, we should use the default value provided by the provider's schema or `null`. We should use `dynamic` block with default omitted configuration when adding a new nested block inside a `resource` block.

## When we have to introduce breaking changes

When we have to introduce breaking changes, we must release it as a Major version upgrade.

## Potential breaking(suprise) changes introduced by `resource` block

1. Adding a new `resource` without `count` or `for_each` for conditional creation, or creating by default
2. Adding a new argument assignment with a value other than the default value provided by the provider's schema
3. Adding a new nested block without making it `dynamic` or omitting it by default
4. Renaming a `resource` block without one or more corresponding `moved` blocks
5. Change `resource`'s `count` to `for_each`, or vice versa

## Potential breaking changes introduced by `variable` and `output` blocks

1. Deleting(Renaming) a `variable`
2. Changing `type` in a `variable` block
3. Changing the `default` value in a `variable` block
4. Changing `variable`'s `nullable` to `true`
5. Changing `variable`'s `sensitive` from `false` to `true`
6. Adding a new `variable` without `default`
7. Deleting an `output`
8. Changing an `output`
9. Changing an `output`'s `sensitive` value

These changes do not necessarily trigger breaking changes, but they are very likely to.
# Rules for `output`

## `output` should be arranged alphabetically

## Name and `description` of an `output` should be consistent with related `description` of `resource` parameters in the official documents

## `output` contains confidential data should declare `sensitive = true`

## Do not declare `sensitive = false`

## A blank line should exist between 2 `output`s

## Dealing with Deprecated `output`s

Sometimes we notice that the name of certain `output` is not appropriate anymore, however, since we have to ensure forward compatibility in the same major version, it's not allowed to change the name directly. We need to move it to an independent `deprecated-outputs.tf` file, then redefine a new output in `output.tf` and make sure it's compatible everywhere else in the module.

A clean up can be performed to `deprecated-outputs.tf` and other logics related to compatibility during a major version upgrade.
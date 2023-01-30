# General Rules

## Definitions

All directories containing Terraform files can be seen as a Terraform module. The module used to define the deployment and interacts with Terraform state file is the root module, others are child modules. The Terraform modules mentioned below are all child modules if not specified.

This article would like to define a set of rules for Terraform child module composing, and encourage child modules with the following features:

* Instead of making a large and comprehensive module, make modules for specific scenarios （Eg. [dynamic-subnets](https://registry.terraform.io/modules/cloudposse/dynamic-subnets/aws/latest) vs [named-subnets](https://registry.terraform.io/modules/cloudposse/named-subnets/aws/latest))
* Unless explicitly set, defaults to obey the security rules
* Unless explicitly set, defaults to ensure the safety of state data
* Make sure users who are familiar with official documentation of involved `resource`, `data` also feel familiar with `variable` and `output` defined in the module, misunderstanding should be reduced to the maximum extent
* Users of the module should have greater privileges, user inputs should be able to override the default value provided. Make as many arguments configurable as possible, unless the restrictions are intended.
* Provide test suites that can be easily executed after a quick environment setup for ops
* Provide complete example code as simple as possible for users to quickly demonstrate the module
* Ensure the latest version of example code can work with the API of the current cloud service at anytime
* Use tools to demonstrate the code is compliant with major security rules
* Keep the consistency of code style with other modules compliant with this rule set

This rule set is an extension of the documents below, it is default to follow these listed rules first:
* [Terraform Style Conventions](https://www.terraform.io/language/syntax/style)
* [Module Creation - Recommended Pattern](https://learn.hashicorp.com/tutorials/terraform/pattern-module-creation?in=terraform/modules)
* Terraform Style Guide

This set of rules is made for modules developed for Azure. If sample code is required in the following chapters, Azure resources should be used in the examples.

## Module Version Requirements

Since Terraform 0.13, `count`, `for_each` and `depends_on` are introduced for modules, module development is significantly simplified (Eg. since `count` is supported now, there is no need to design params like `enabled` or `module_depends_on`). For modules described in this article, the minimum required version of Terraform is 1.1.0.

## Purpose of Modules

A module should focus on the best practice of a specific service under a certain usage scenario. The resources in the module should be highly cohesive, and the module should be easy to composite with other modules and resources.

Modules should have a consistent style with the official documentation of involved `resource`, `data`, as well as other modules following these rules. A consistent user experience should be provided at all times to reduce the risk of mistakes and misunderstandings.

## Types of Modules

Based on the purpose, there are 2 types of modules.

1. Modules to create real `resource`
2. Modules contain only `variable`, `locals` and `output`

The modules mentioned below are the first type if not specified.

## Design of Modules

A module should refer to the concept of aggregated root in DDD (Domain Driven Development), there will be a leading resource and a series of resources work with it.

The information aggregated root resource depends on should be passed through corresponding `variable` instead of creating on its own or inquiring with `data`. [HashiCorp defined dependency-inversion](https://www.terraform.io/docs/language/modules/develop/composition.html#dependency-inversion) should be practiced.

## Consist of a Module

```config
.
├── LICENSE
├── GNUmakefile
├── README.md
├── CHANGELOG.md
├── context.tf
├── examples
│   └── startup
│       ├── context.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── versions.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── test
│   ├── Makefile.alpine
│   ├── e2e
│   ├── go.mod
│   ├── upgrade
|   └── unit_test
├── variables.tf
└── versions.tf
```

This is a typical structure of a module project.

A Module consists of an auto-generated part and the repo's maintainer-composed part.

The below parts should be written by the author:

* Logical code of the module - all `.tf` files under the root directory
* documentation - `README.md`
* Automated tests - `e2e`, `upgrade` and `unit_test` directories under `test` directory
* Examples - `example` directory

The rest parts rely on code auto-generation. The author should not modify the content of these auto-generated files. The content will be generated automatically before every commit and overwrite the previous contents.

We consider these parts equally important, so they should have the same code quality standard.

## Static Files and Template Files

Under some scenarios the static file and template files the module will use are saved under `files` directory.

Template files for Terraform [`templatefile` function's](https://www.terraform.io/docs/configuration/functions/templatefile.html) use should be named as `.tftpl` and placed under `template` directory.

## Semantic Versioning

All modules are managed by [semantic versioning](https://semver.org/), the version number looks like this:

>vX.Y.Z

In the version number:

* X is the major version, a major change can introduce breaking changes, that means we consider `v.1.9.0` and `v2.0.0` 2 different softwares, users who perform such upgrade should be prepared for adjusting code invoked or Terraform plan changes.
* Y is the minor version, a minor change **cannot** include breaking changes, only forward compatible features or functional bug fix without breaking forward compatible principle can be introduced.
* Z is the patch, a patch **cannot** include breaking changes, it can only fix behaviors that break forward compatible principle. When a breaking change is detected after a minor version release, a quick patch can be rolled out for fixing.

## Module Languages

Since we have employed some homemade TFLint plugins, and it's a lot of work to make these plugins support HCL and Json at the same time, now we only allow HCL for module composing. Json formatted module is expected to be supported in the future.
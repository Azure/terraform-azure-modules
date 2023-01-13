# Testing code

All module projects should come with an automated test in a folder named as `test`.

[Terratest](https://terratest.gruntwork.io/) framework is recommended for automated test, use [testify](https://github.com/stretchr/testify) as assertion library.

There are 3 types of [unit tests](../test_code/unit_test.md), [e2e tests](../test_code/e2e_test.md) and [version upgrade tests](../test_code/version_upgrade_tests.md)
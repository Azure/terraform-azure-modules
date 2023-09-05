#!/usr/bin/env bash
echo "=========> terragrunt init"
terragrunt init || echo "Terraform init error but we tolerate it here."
echo "=========> terragrunt init -reconfigure"
terragrunt init -reconfigure
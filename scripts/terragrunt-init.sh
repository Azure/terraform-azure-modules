#!/usr/bin/env bash
echo "=========> terraform init"
terraform init || echo "Terraform init error but we tolerate it here."
echo "=========> terraform init -reconfigure"
terraform init -reconfigure
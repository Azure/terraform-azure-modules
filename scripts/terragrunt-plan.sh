#!/usr/bin/env bash
terragrunt plan -out tfplan
echo $'```text\n' > log.txt\
echo '=========> Existing resources:' >> log.txt
terragrunt state list >> log.txt
terraform show -no-color tfplan >> log.txt
echo '```' >> log.txt
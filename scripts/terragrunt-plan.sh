#!/usr/bin/env bash
terraform plan -out tfplan
echo $'```text\n' > log.txt\
echo '=========> Existing resources:' >> log.txt
terraform state list >> log.txt
terraform show -no-color tfplan >> log.txt
echo '```' >> log.txt
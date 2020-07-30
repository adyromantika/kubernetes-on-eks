#!/bin/sh

# Runs Terraform validation from within a docker container
# Meant to be run from Travis

cd /kubernetes-on-eks
terraform init -backend=false
terraform version
terraform validate

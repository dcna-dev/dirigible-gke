# dirigible-gke

Terraform modules to deploy Eclipse Dirigible in Google Kubernets Engine.

This can use with pure Terraform file or with Terragrunt, like in https://github.com/dcna-io/dirigible-docker/

# To execute the tests


- Go to test/app/
- Follow the oficial instructions to install terratest: https://github.com/gruntwork-io/terratest
- Modify the variables in varfiles.tfvars.example and rename to varfiles.tfvars
- Modify backend variables in terraform_app_test.go in all functions
- Execute: go test -v terraform_app_test.go

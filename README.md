# dirigible-gke

Terraform modules to deploy Eclipse Dirigible in Google Kubernets Engine.

This can use with pure Terraform file or with Terragrunt, like in https://github.com/dcna-io/dirigible-docker/

# To execute the tests

1. Before the test you will need build the image and send to Google Cloud Registry. Please, follow the 1 to 6 instructions in https://github.com/dcna-io/dirigible-docker
2. Go to test/app/
3. Follow the oficial instructions to install terratest: https://github.com/gruntwork-io/terratest
4. Modify the variables in varfiles.tfvars.example and rename to varfiles.tfvars
5. Modify backend variables in terraform_app_test.go in all functions
6. Execute: ``` go test -v terraform_app_test.go ```

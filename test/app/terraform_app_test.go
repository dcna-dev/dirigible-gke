package test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformGcpExample(t *testing.T) {
	t.Parallel()
	// Backend variables
	bucket := ""
	projectId := "gcp-project"
	prefix := "gke"
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../gke/",

		VarFiles: []string{"../test/app/varfile.tfvars"},
		BackendConfig: map[string]interface{}{
			"bucket":  bucket,
			"prefix":  prefix,
			"project": projectId,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of some of the output variables
	client_certificate := terraform.Output(t, terraformOptions, "client_certificate")
	client_key := terraform.Output(t, terraformOptions, "client_key")
	cluster_ca_certificate := terraform.Output(t, terraformOptions, "cluster_ca_certificate")
	host := terraform.Output(t, terraformOptions, "host")

	if host == "" {
		t.Errorf("Variable host is empty!")
	}

	if client_key == "" {
		t.Errorf("Variable client_key is empty!")
	}

	if cluster_ca_certificate == "" {
		t.Errorf("Variable cluster_ca_certificate is empty!")
	}

	if client_certificate == "" {
		t.Errorf("Variable client_certificate is empty!")
	}

	deployPostgresql(t, client_certificate, client_key, cluster_ca_certificate, host)
}

func deployPostgresql(t *testing.T, client_certificate string, client_key string, cluster_ca_certificate string, host string) {
	//Backend variables
	bucket := ""
	projectId := "gcp-project"
	prefix_postgres := "postgresql"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../postgresql",

		Vars: map[string]interface{}{
			"client_certificate":     client_certificate,
			"client_key":             client_key,
			"cluster_ca_certificate": cluster_ca_certificate,
			"host": host,
		},

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"../test/app/varfile.tfvars"},
		BackendConfig: map[string]interface{}{
			"bucket":  bucket,
			"prefix":  prefix_postgres,
			"project": projectId,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	deployDirigible(t, client_certificate, client_key, cluster_ca_certificate, host)
}

func deployDirigible(t *testing.T, client_certificate string, client_key string, cluster_ca_certificate string, host string) {
	//Backend variables
	bucket := ""
	projectId := "gcp-project"
	prefix_postgres := "app"

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../app",

		Vars: map[string]interface{}{
			"client_certificate":     client_certificate,
			"client_key":             client_key,
			"cluster_ca_certificate": cluster_ca_certificate,
			"host": host,
		},

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"../test/app/varfile.tfvars"},
		BackendConfig: map[string]interface{}{
			"bucket":  bucket,
			"prefix":  prefix_postgres,
			"project": projectId,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	lb_ip := terraform.Output(t, terraformOptions, "lb_ip")
	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	// Verify that we get back a 200 OK with the expected instanceText
	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		fmt.Sprintf("http://%s", lb_ip),
		maxRetries,
		timeBetweenRetries,
		func(statusCode int, body string) bool {
			return statusCode == 200
		},
	)
}

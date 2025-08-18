terraform {
  backend "s3" {
    # Backend configuration will be provided during init
    # via -backend-config flags or backend config file
    # Key is dynamically set in GitHub Actions:
    # - dev: /dev/terraform.tfstate
    # - prod: /prod/terraform.tfstate
    encrypt = true
  }
}

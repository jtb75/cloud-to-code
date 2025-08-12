terraform {
  backend "s3" {
    # Backend configuration will be provided during init
    # via -backend-config flags or backend config file
    encrypt = true
  }
}
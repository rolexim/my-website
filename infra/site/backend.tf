terraform {
  # Partial config — bucket and key passed at `terraform init` via
  # -backend-config or a backend.hcl file. See README for the exact init
  # command. State locking uses the S3-native lockfile (Terraform 1.10+).
  backend "s3" {
    key          = "site/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

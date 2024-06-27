terraform {
  backend "s3" {
    bucket = "tfstate"
    key    = "tf-azure/terraform.tfstate"

    endpoints = { s3 = "https://s3.us-east-va.io.cloud.ovh.us" }
    # export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
    # export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY 

    region                      = "us-east-va"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true # Optional, set to true if MinIO does not support AWS account ID
  }
}
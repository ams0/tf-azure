terraform {
  backend "s3" {
    bucket = "tfstate"
    key    = "tf-azure/terraform.tfstate"

    endpoints = { s3 = "https://s3.cloud.kubespaces.io" }


    region                      = "cloud"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true # Optional, set to true if MinIO does not support AWS account ID
  }
}
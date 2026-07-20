terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    endpoint = "storage.yandexcloud.net"

    bucket = "tfstate-mapfoi37"
    key    = "terraform.tfstate"
    region = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
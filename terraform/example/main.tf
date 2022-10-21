module "fourkeys" {
  source              = "../modules/fourkeys"
  project_id          = var.project_id
  enable_apis         = var.enable_apis
  enable_build_images = var.enable_build_images
  region              = var.region
  bigquery_region     = var.bigquery_region
  parsers             = var.parsers
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.17.0"
    }
  }

  backend "gcs" {
    bucket = "mikan-fourkeys-terraform-tfstate"
  }
}

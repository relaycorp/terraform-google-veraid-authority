terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.10.2"
    }
  }
}

provider "google" {
  project     = var.google_project_id
  credentials = file(var.google_credentials_path)
}

provider "google-beta" {
  project     = var.google_project_id
  credentials = file(var.google_credentials_path)
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

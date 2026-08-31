terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.77.0, < 8.0.1"
    }
  }
}

resource "random_id" "unique_suffix" {
  byte_length = 3
}

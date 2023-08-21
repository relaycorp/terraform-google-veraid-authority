// TODO: RENAME TO "name" or "instance_name"
variable "backend_name" {
  description = "The name of the backend"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.backend_name))
    error_message = "Backend name must be between 1 and 10 characters long, and contain only lowercase letters and digits"
  }
}

# ===== GCP

variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

# ===== MongoDB

variable "mongodb_uri" {
  description = "The MongoDB URI"
  type        = string
}
variable "mongodb_db" {
  description = "The MongoDB database name"
  type        = string
}
variable "mongodb_user" {
  description = "The MongoDB username"
  type        = string
}
variable "mongodb_password" {
  description = "The MongoDB password"
  type        = string
  sensitive   = true
}

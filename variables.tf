variable "docker_image_name" {
  description = "The Docker image to deploy"
  default     = "relaycorp/veraid-authority"
}

variable "docker_image_tag" {
  description = "The Docker image tag to deploy (highly recommended to set this explicitly)"
  default     = "1.22.0"
}

variable "instance_name" {
  description = "The name of the backend"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.instance_name))
    error_message = "Backend name must be between 1 and 10 characters long, and contain only lowercase letters and digits"
  }
}

variable "log_level" {
  description = "The log level (trace, debug, info, warn, error, fatal)"
  type        = string
  default     = "info"

  validation {
    condition = contains(["trace", "debug", "info", "warn", "error", "fatal"], var.log_level)

    error_message = "Invalid log level"
  }
}

# ===== API Authentication
variable "api_auth_jwks_url" {
  description = "The URL of the JWKS endpoint"
  type        = string
  default     = "https://www.googleapis.com/oauth2/v3/certs"
}
variable "api_auth_token_issuer" {
  description = "The OAuth2 token issuer"
  type        = string
  default     = "https://accounts.google.com"
}
variable "api_auth_audiences" {
  description = "The OAuth2 audiences"
  type        = list(string)
}
variable "superadmin_email" {
  description = "The email address of the superadmin ('email' claim in JWT)"
  default     = null
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

variable "kms_protection_level" {
  description = "The KMS protection level (SOFTWARE or HSM)"
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.kms_protection_level)
    error_message = "KMS protection level must be either SOFTWARE or HSM"
  }
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

# ====== API

variable "api_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the API server)"
  type        = number
  default     = 80
}
variable "api_min_instance_count" {
  description = "The minimum number of instances (for the API server)"
  type        = number
  default     = 1
}
variable "api_max_instance_count" {
  description = "The maximum number of instances (for the API server)"
  type        = number
  default     = 3
}

# ====== Background queue

variable "queue_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the queue server)"
  type        = number
  default     = 80
}
variable "queue_min_instance_count" {
  description = "The minimum number of instances (for the queue server)"
  type        = number
  default     = 1
}
variable "queue_max_instance_count" {
  description = "The maximum number of instances (for the queue server)"
  type        = number
  default     = 3
}

variable "queue_member_bundle_trigger_schedule_utc" {
  description = "The CRON schedule for the member bundle trigger (UTC)"
  type        = string
  default     = "0 9 * * *"
}

# ====== Awala Internet Endpoint backend

variable "awala_backend_max_instance_request_concurrency" {
  description = "The maximum number of concurrent requests per instance (for the Awala backend)"
  type        = number
  default     = 80
}
variable "awala_backend_min_instance_count" {
  description = "The minimum number of instances (for the Awala backend)"
  type        = number
  default     = 1
}
variable "awala_backend_max_instance_count" {
  description = "The maximum number of instances (for the Awala backend)"
  type        = number
  default     = 3
}

# ===== Awala Internet Endpoint

variable "awala_endpoint_enabled" {
  description = "Whether to enable Awala support"
  type        = bool
  default     = false
}

variable "awala_endpoint_outgoing_messages_topic" {
  description = "The name of the Pub/Sub topic for outgoing messages"
  type        = string
  default     = null
}
variable "awala_endpoint_incoming_messages_topic" {
  description = "The name of the Pub/Sub topic for incoming messages"
  type        = string
  default     = null
}

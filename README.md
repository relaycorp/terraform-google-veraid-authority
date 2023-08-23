# Terraform module `relaycorp/veraid-authority/google`

This is a Terraform module to manage an instance of [VeraId Authority](https://docs.relaycorp.tech/veraid-authority/) on Google Cloud Platform (GCP) using serverless services.

The module is responsible for all the resources needed to run the endpoint app on GCP, except for the following (which you can deploy to any cloud and any region):

- The MongoDB server.
- The [Awala Internet Endpoint](https://registry.terraform.io/modules/relaycorp/awala-endpoint/google/latest), if you're using the [Awala integration](https://docs.relaycorp.tech/veraid-authority/awala). Refer to [the `awala` example](./examples/awala) for a full example with the Awala Internet Endpoint.
- Resources related to the identity provider (e.g., Auth0, Google).

The [following diagram](https://github.com/relaycorp/terraform-google-veraid-authority/blob/main/diagrams/diagram-without-awala.svg) illustrates the cloud architecture created by this module (without the Awala integration):

![](./diagrams/diagram-without-awala.svg)

## Prerequisites

- A GCP project with billing and the [Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview) enabled.
- A domain name with DNSSEC correctly configured.
- A MongoDB server reachable from the Cloud Run resources.
- An [Awala Internet Endpoint](https://registry.terraform.io/modules/relaycorp/awala-endpoint/google/latest) setup, if you're using the [Awala integration](https://docs.relaycorp.tech/veraid-authority/awala).

## Install

1. Enable the required service APIs and initialise this module in a new module. For example:
   ```hcl
      locals {
         services = [
            "run.googleapis.com",
            "compute.googleapis.com",
            "cloudkms.googleapis.com",
            "pubsub.googleapis.com",
            "secretmanager.googleapis.com",
            "iam.googleapis.com",
         ]
      }

      resource "google_project_service" "services" {
         for_each = toset(local.services)

         project                    = var.google_project
         service                    = each.value
         disable_dependent_services = true
      }

     module "veraid-authority" {
       source  = "relaycorp/veraid-authority/google"
       version = "<INSERT VERSION HERE>"
   
       # ... Specify the variables here...
     }
   ```
   [See full example](examples/basic).
2. Run `terraform init`, followed by `terraform apply`.

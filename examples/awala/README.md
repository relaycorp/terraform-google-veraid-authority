# Deployment of VeraId Authority with Awala support to GCP

This Terraform module provides an example of how to deploy VeraId Authority to Google Cloud Platform (GCP) and MongoDB Atlas using serverless resources. It also assumes you'll be using Google as the identity provider.

For a simpler example without Awala, refer to [the `basic` example](../basic).

## Install

1. Configure authentication. Go to [Credentials](https://console.cloud.google.com/apis/credentials) in the Google Cloud Console, and create a new OAuth2 client ID with the following parameters:
   - Application type: Web application.
   - Authorised redirect URIs: `https://jwt.io`

   Then copy the client id.
2. Log in to Google using the following URL, replacing `YOUR_CLIENT_ID` with the id you got above:
   ```
   https://accounts.google.com/o/oauth2/v2/auth?client_id=YOUR_CLIENT_ID&redirect_uri=https%3A%2F%2Fjwt.io&response_type=id_token&scope=https://www.googleapis.com/auth/userinfo.profile%20https://www.googleapis.com/auth/userinfo.email&nonce=random
   ```
   
    You'll be redirected to [jwt.io](https://jwt.io) with a JWT in the URL. Copy the value of the `sub` claim.
3. Initialise this module with the required variables. For example:
   ```hcl
     module "veraid-authority-awala" {
       source  = "relaycorp/veraid-authority/google//examples/basic"
       version = "<INSERT VERSION HERE>"
   
       google_project_id = "your-project"
       # Use environment variables in production
       google_credentials_path = "/home/you/Desktop/google-credentials.json"

       mongodbatlas_public_key  = "your-public-key-id"
       mongodbatlas_private_key = "your-private-key"
       mongodbatlas_project_id  = "your-project-id"

       api_auth_audience        = "your-oauth2-client-id"
       superadmin_email_address = "your-jwt-sub" # The "sub" claim of the JWT you got above
   
       awala_internet_address       = "your-domain-name" # e.g., "your-company.com"
       awala_internet_pohttp_domain = "your-pohttp-domain" # e.g., "pohttp.your-company.com
     }
   ```
4. Run `terraform init`, followed by `terraform apply`.
5. Copy the outputs `pohttp_server_ip_address` and `bootstrap_job_name` to complete the setup of the Awala Internet Gateway per the instructions of the [Awala Internet Endpoint module](https://registry.terraform.io/modules/relaycorp/awala-endpoint/google/latest).

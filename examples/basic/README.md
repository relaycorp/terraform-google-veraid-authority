# VeraId Authority example

1. Configure authentication. For example, to use Google as the provider, go to [Credentials](https://console.cloud.google.com/apis/credentials) in the Google Cloud Console, and create a new OAuth2 client ID with the following parameters:
   - Application type: Web application.
   - Authorised redirect URIs: `https://jwt.io`
   
   Copy the client id.
2. Log in to Google using the following URL, replacing `YOUR_CLIENT_ID` with the id you got above:
   ```
   https://accounts.google.com/o/oauth2/v2/auth?client_id=YOUR_CLIENT_ID&redirect_uri=https%3A%2F%2Fjwt.io&response_type=id_token&scope=https://www.googleapis.com/auth/userinfo.profile%20https://www.googleapis.com/auth/userinfo.email&nonce=random
   ```

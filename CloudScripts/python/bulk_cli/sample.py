# Credentials can begotten with this https://google-auth.readthedocs.io/en/latest/reference/google.auth.html#google.auth.default

import google.auth
import googleapiclient.discovery
from oauth2client.client import GoogleCredentials

credentials, project_id = google.auth.default()

resource_manager = googleapiclient.discovery.build('cloudresourcemanager', 'v2', credentials=credentials)

response = resource_manager.folders().list(parent="organizations/383705642747").execute()

print(response)

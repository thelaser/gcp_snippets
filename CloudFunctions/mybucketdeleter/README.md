The classical auto-deleting bucket

The Cloud SDK looks for a main.py file if using Python, as stated in the [docs](https://cloud.google.com/sdk/gcloud/reference/functions/deploy#--source)

Can be created or updated with the following command([reference](https://cloud.google.com/sdk/gcloud/reference/functions/deploy):

`gcloud functions deploy --region europe-west1 --runtime=python37 --trigger-event=google.storage.object.finalize --trigger-resource=<your-bucket> --entry-point=getrekt autodeleter`

If it fails, read logs with:

`gcloud functions logs read <funcname> --region <region>


Related links of interest:
https://cloud.google.com/sdk/gcloud/reference/functions/deploy
https://cloud.google.com/sdk/gcloud/reference/functions/event-types/list
https://cloud.google.com/sdk/gcloud/reference/functions/deploy#--source
https://cloud.google.com/functions/docs/concepts/events-triggers
https://cloud.google.com/functions/docs/writing/background#cloud-storage-example
https://cloud.google.com/functions/docs/writing/background#function_parameters
https://cloud.google.com/storage/docs/json_api/v1/objects#resource
https://pypi.org/project/google-cloud-storage/
https://googleapis.dev/python/storage/latest/index.html
https://cloud.google.com/storage/docs/json_api/v1

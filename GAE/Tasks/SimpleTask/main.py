from flask import Flask, render_template
from google.cloud import tasks_v2beta3
from google.protobuf import timestamp_pb2
import os

app = Flask(__name__)

@app.route("/")
def index():
   return render_template('index.html')

@app.route('/createtask')
def createTask():

    # In order to debug this in a GCE instance, one must create a SA with the 'Cloud Tasks Enqueuer' role, get the JSON key and point to the key with this line below.
    # Note this must be done before the client is created, otherwise it won't be using our JSON key.
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "<path_to_key>.json"

    # Create a client.
    client = tasks_v2beta3.CloudTasksClient()

    # TODO(developer): Uncomment these lines and replace with your values.
    project = '<projectID>'
    queue = '<queueName>'
    location = '<queueLocation>'
    url = '<URLtoCloudFunctionsEndpoint>'
    payload = ''

    # Construct the fully qualified queue name.
    parent = client.queue_path(project, location, queue)

    # Construct the request body.
    task = {
            'http_request': {  # Specify the type of request.
                'http_method': 'GET',
                'url': url  # The full url path that the task will be sent to.
            }
    }
    if payload is not None:
        # The API expects a payload of type bytes.
        converted_payload = payload.encode()

        # Add the payload to the request.
        task['http_request']['body'] = converted_payload


    # Use the client to build and send the task.
    response = client.create_task(parent, task)

    return 'Created task {}'.format(response.name)

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=80)

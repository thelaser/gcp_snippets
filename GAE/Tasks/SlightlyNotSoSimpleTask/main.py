from flask import Flask, render_template, request
from google.cloud import tasks_v2beta3
from google.protobuf import timestamp_pb2
import os
import requests 
import json

app = Flask(__name__)

@app.route("/")
def index():
	return render_template('index.html')

@app.route('/createqueuegae', methods=["POST"])
def createQueue():
	# In order to debug this in a GCE instance, one must create a SA with the 'Cloud Tasks Enqueuer' role, get the JSON key and point to the key with this line below.
	# Note this must be done before the client is created, otherwise it won't be using our JSON key. Once uploaded to GAE, we don't need this line, and we should delete
	# the Service Account's key from the /key folder.
	# os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./key/mykey.json"

	# Create a client.
	client = tasks_v2beta3.CloudTasksClient()

	req = request.form

	location = req.get("location")
	project = req.get("project_id")
	queue_name = req.get("queue_name")
	queue_body = {
		# The fully qualified path to the queue
		'name': client.queue_path(project, location, queue_name),
	}

	# Use the client to build and send the task.
	response = client.create_queue("projects/"+project+"/locations/"+location, queue_body)

	return 'Created queue {}'.format(response.name)

@app.route('/createtaskgae', methods=["POST"])
def createTask():

	#os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "./key/mykey.json"

	# Create a client.
	client = tasks_v2beta3.CloudTasksClient()

	req = request.form

	queue = req.get("queue_name")
	location = req.get("location")
	project = req.get("project_id")
	url = '<link to the HTTP Trigger for a Cloud Function>'

	# Construct the fully qualified queue name.
	parent = client.queue_path(project, location, queue)

	# Construct the request body.
	task = {
					'http_request': {  # Specify the type of request.
							'http_method': 'GET',
							'url': url  # The full url path that the task will be sent to.
					}
	}


	# Use the client to build and send the task.
	response = client.create_task(parent, task)

	return 'Created task {}'.format(response.name)


@app.route('/createqueuecf', methods=["POST"])
def createQueueCF():
	req = request.form

	queue_name = req.get("queue_name")
	location = req.get("location")
	project_id = req.get("project_id")
	
	data = {'queue_name':queue_name,
			'location':location,
			'project_id':project_id}
	
	cf_endpoint = "<link to the trigger of the CF which creates Queues>"

	my_headers = {'Content-Type': 'application/json'}

	# sending post request and saving response as response object 
	r = requests.post(url = cf_endpoint, data = json.dumps(data), headers = my_headers) 

	return r.text

@app.route('/createtaskcf', methods=["POST"])
def createTaskCF():
	req = request.form

	queue_name = req.get("queue_name")
	location = req.get("location")
	project_id = req.get("project_id")
	
	data = {'queue_name':queue_name,
			'location':location,
			'project_id':project_id}
	
	cf_endpoint = "<link to the HTTP trigger of the CF which creates Tasks>"

	my_headers = {'Content-Type': 'application/json'}

	# sending post request and saving response as response object 
	r = requests.post(url = cf_endpoint, data = json.dumps(data), headers = my_headers) 

	return r.text

# port should be changed to 80
if __name__ == '__main__':
  app.run(host='0.0.0.0', port=8080)

def create_task(request):
    
    from google.cloud import tasks_v2beta3
    
    request_json = request.get_json(silent=True)
    request_args = request.args
    
    print(request_json)
    print(request_args)

    if request_json and (('queue_name' and 'location' and 'project_id')  in request_json):
        
        print("here we go again")
        
        queue = request_json['queue_name']
        location = request_json['location']
        project = request_json['project_id']
        url = 'https://us-central1-myplaygrounds-paugarcia.cloudfunctions.net/function-1'
        
        task = {
        	'http_request': {  # Specify the type of request.
            	'http_method': 'GET',
            	'url': url  # The full url path that the task will be sent to.
        	}
		}
        
        client = tasks_v2beta3.CloudTasksClient()
        parent = client.queue_path(project, location, queue)
        
        
        response = client.create_task(parent, task)
        return 'Created task {}'.format(response.name)
        
    #elif request_args and 'name' in request_args:
        #name = request_args['name']
    else:
        return "Didn't work"

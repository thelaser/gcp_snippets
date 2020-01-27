def create_queue(request):

    from google.cloud import tasks_v2beta3

    request_json = request.get_json(silent=True)
    request_args = request.args

    print(request_json)
    print(request_args)

    if request_json and (('queue_name' and 'location' and 'project_id')  in request_json):

        print("here we go again")
        
        client = tasks_v2beta3.CloudTasksClient()

        queue_name = request_json['queue_name']
        location = request_json['location']
        project = request_json['project_id']
        queue = {
            # The fully qualified path to the queue
            'name': client.queue_path(project, location, queue_name),
      	}
        
        # Use the client to build and send the task.
        response = client.create_queue("projects/"+project+"/locations/"+location, queue)
        
        return 'Created queue {}'.format(response.name)

    #elif request_args and 'name' in request_args:
        #name = request_args['name']
    else:
        return "Didn't work"

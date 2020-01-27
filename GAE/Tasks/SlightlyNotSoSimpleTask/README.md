This is an example usage of App Engine with Python3 using the Cloud Tasks library to create some tasks and queues, as well as relaying of JSON messages to Cloud Functions using the `requests` library to perform POST requests.


To debug locally, one must create a SA account with the 'Cloud Tasks Enqueuer', get the Service Account JSON key and put it in the keys/ folder.
Afterwards, modify the main.py file to uncomment the commands that load the JSON keys.  

Remember to create a virtual environment with `python3 -m venv myenv` and install dependencies with `sudo pip install -r requirements.txt` and then run with `sudo python main.py`.  

In order to make it work, one must also create the Cloud Functions in the CloudFunctionsCode and add them to the code in the several `url` variables.

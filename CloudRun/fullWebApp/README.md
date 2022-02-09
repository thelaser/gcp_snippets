# Scenario

## Process

https://cloud.google.com/community/tutorials/building-flask-api-with-cloud-firestore-and-deploying-to-cloud-run

### Live date and messages

REMEMBER: change 80 to $PORT in Dockerfile

Lookup in the internet a sample that does what I need
https://www.plus2net.com/javascript_tutorial/clock.php

Copy previous Cloud Run sample from a simpler activity
https://github.com/thelaser/gcp_snippets/tree/master/CloudRun/SimpleTask

Put all the previous together and try if the website works locally by installing python and flask and then running it allinside a Docker container using the Dockerfile that will be used with Cloud Run.

docker build -t localtest .
docker run -p 80:80 -d localtest
Debug container errors with docker logs ID

Once the first part(live date and sample button) works, let's go with the messages.

We can also use online services to quickly test HTML, JS and CSS.
https://codepen.io/pen/
http://jsbin.com/



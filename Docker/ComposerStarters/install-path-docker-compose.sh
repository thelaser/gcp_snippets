# The following dependencies are necessary for the alpine version : py-pip python-dev libffi-dev openssl-dev gcc libc-dev make

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

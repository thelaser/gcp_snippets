To make this work, one must create a SA account with the 'Cloud Tasks Enqueuer', get the Service Account JSON key and put it in the keys/ folder.
Afterwards, modify the main.py file with your details like projectID and such.

Also if one is to debug one should install dependencies with `sudo pip install -r requirements.txt` and then run with `sudo python main.py`. Sudo is used because the port to open is the 80 at 0.0.0.0

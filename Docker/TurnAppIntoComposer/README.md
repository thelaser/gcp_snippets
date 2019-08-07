# About

A normal webapp without containerization is turned into a containerized app.

Concretely we take this [GitHub database app](https://github.com/taniarascia/pdo) and turn it into a Composer ready app.

In order for this to work, you must have [Docker](https://docs.docker.com/install/linux/docker-ce/debian/) installed, and also [Docker Composer](https://docs.docker.com/compose/install/). Assuming you installed Docker and Composer and have Composer in your path, in order to run this code, you must do the following:
```
git clone https://github.com/thelaser/gcp_snippets
cd gcp_snippets/Docker/TurnAppIntoComposer
docker-compose up
```

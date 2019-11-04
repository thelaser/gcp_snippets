# Deploying a managed instance group with an autoscaler using DM

We use the `main.yaml` file to import the JINJA template files and deploy what's inside of them.

In the `*.jinja` files we define each resource that is going to be deployed.

In the `*.jinja.schema` files we define variables we can later use in the YAML file, that will affect the resources created by the JINJA files.

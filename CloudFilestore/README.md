# How to run

## A foreword
WARNING: This is a very simple script, it does not provide a method to remove what was created or to remove trash generated in case of error. A recommended approach to automate this is to use Terraform, for example, which deletes all trash in case of error creation, etc.

**TL;DR This could get hella messy yall, be careful**

## Overview

This is a script that automates what is detailed in [this guide](https://cloud.google.com/run/docs/tutorials/network-filesystems-filestore)

The files used for deployment (minus the autorun.sh script) come from [this repo](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/run/filesystem)

You can run the bash script and change the variables defined in the beginning with your own.

There is an extra step not included in the guide, where specific permissions are assigned to the service account, Cloud Run Admin and Service Account User. This needs to be mentioned in the guide.

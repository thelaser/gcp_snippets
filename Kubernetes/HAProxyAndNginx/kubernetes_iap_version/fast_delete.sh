#!/bin/bash

k delete pods proxypods

k delete service myproxysample

k delete secrets my-secret

k delete backendconfigs.cloud.google.com config-proxiedservice

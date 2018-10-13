#!/bin/bash

# Setting environment variables

export CLUSTER_NAME=knative-01
export CLUSTER_ZONE=us-central1-c
export KNATIVE_PROJECT=idv-knative-01

# To delete the cluster, enter the following command (removing '#' before):

gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE

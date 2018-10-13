#!/bin/bash

# Setting environment variables

export CLUSTER_NAME=knative-01
export CLUSTER_ZONE=us-central1-c
export KNATIVE_PROJECT=idv-knative-01

# Set the default project in gcloud shell
gcloud config set project $KNATIVE_PROJECT

# Enabling the necessary APIs
gcloud services enable \
  cloudapis.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com
  
# Create a GKE cluster
gcloud container clusters create $CLUSTER_NAME \
  --zone=$CLUSTER_ZONE \
  --cluster-version=latest \
  --machine-type=n1-standard-4 \
  --enable-autoscaling --min-nodes=1 --max-nodes=10 \
  --enable-autorepair \
  --scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore \
  --num-nodes=3
  
# To authenticate for the cluster, run the following command:
gcloud container clusters get-credentials $CLUSTER_NAME

# Grant cluster-admin permissions to the current user:
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)

# Install Istio:
kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.1.1/third_party/istio-0.8.0/istio.yaml

# Label the default namespace with istio-injection=enabled:
kubectl label namespace default istio-injection=enabled
# Monitor the Istio components until all of the components show a STATUS of Running or Completed:
kubectl get pods --namespace istio-system

# Installing Knative Serving and Build components
# Run the kubectl apply command to install Knative and its dependencies:
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.1.1/release.yaml

# Monitor the Knative components until all of the components show a STATUS of Running:
kubectl get pods --namespace knative-serving
kubectl get pods --namespace knative-build

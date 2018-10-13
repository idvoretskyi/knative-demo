knative-demo
============

A brief and small demo of [Knative](https://github.com/knative/) - the [Kubernetes](https://kubernetes.io)-based platform to build, deploy, and manage modern serverless workloads

Installing Knative
------------------

The instructions on how to install KNative are available in the official [Knative repo](https://github.com/knative/docs/tree/master/install).

Alternatively, you may install Knative on GKE (Google Kubernetes Engine) just run the [install-knative-gke.sh](install-knative-gke.sh) script, available in this repo, or just copy and paste the following to your shell (use carefully!):

```
curl -sSL https://raw.githubusercontent.com/idvoretskyi/knative-demo/master/install-knative-gke.sh | bash -x
```

PS. This script will create a 3-node Kubernetes cluster on GKE with the *n1-standard-4* machine type. Please, check the GKE documentation to find more details (as well as pricing) about the [machine types](https://cloud.google.com/compute/docs/machine-types).

Deploying Applications
----------------------

TBD

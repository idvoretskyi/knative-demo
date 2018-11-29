knative-demo
============

A brief and small demo of [Knative](https://github.com/knative/) - the [Kubernetes](https://kubernetes.io)-based platform to build, deploy, and manage modern serverless workloads

Installing Knative
------------------

The instructions on how to install KNative are available in the official [Knative repo](https://github.com/knative/docs/tree/master/install).

Alternatively, you may install Knative on GKE (Google Kubernetes Engine) just running the [install-knative-gke.sh](scripts/install-knative-gke.sh) script, available in this repo, or just copy and paste the following to your shell (use carefully!):

```
curl -sSL https://git.io/fpVaH | bash
```

PS. This script will create a 3-node Kubernetes cluster on GKE with the *n1-standard-4* machine type. Please, check the GKE documentation to find more details (as well as pricing) about the [machine types](https://cloud.google.com/compute/docs/machine-types).

Deploying Applications
----------------------

### Hello World Sample

-	Create a new file named `helloworld.go` and paste the following code. This code creates a basic web server which listens on port 8080:

	```go
	package main

	import (
		"flag"
		"fmt"
		"log"
		"net/http"
		"os"
	)

	func handler(w http.ResponseWriter, r *http.Request) {
		log.Print("Hello world received a request.")
		target := os.Getenv("TARGET")
		if target == "" {
			target = "World"
		}
		fmt.Fprintf(w, "Hello %s!\n", target)
	}

	func main() {
		flag.Parse()
		log.Print("Hello world sample started.")

		http.HandleFunc("/", handler)
		http.ListenAndServe(":8080", nil)
	}
	```

	-	Create a `Dockerfile` with the following contents:

	```docker
	# Start from a Debian image with the latest version of Go installed
	# and a workspace (GOPATH) configured at /go.
	FROM golang

	# Copy the local package files to the container's workspace.
	ADD . /go/src/github.com/knative/docs/helloworld

	# Build the helloworld command inside the container.
	# (You may fetch or manage dependencies here,
	# either manually or with a tool like "godep".)
	RUN go install github.com/knative/docs/helloworld

	# Run the helloworld command by default when the container starts.
	ENTRYPOINT /go/bin/helloworld

	# Document that the service listens on port 8080.
	EXPOSE 8080
	```

-	Create a service.yaml file with the following contents:

```yaml
apiVersion: serving.knative.dev/v1alpha1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/${KNATIVE_PROJECT}/helloworld-go # The URL to the image of the app
            env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Go Sample v1"
```

### Building and deploying

-	Build the container image locally:

```shell
docker build -t gcr.io/${KNATIVE_PROJECT}/helloworld-go .
```

-	Push it to the remote registry:

```shell
docker push gcr.io/${KNATIVE_PROJECT}/helloworld-go
```

-	Apply the configuration

	```
	kubectl apply --filename service.yaml
	```

-	Find the IP address of your service (and export it as a system variable):

	```
	kubectl get svc knative-ingressgateway --namespace istio-system
	export IP_ADDRESS=$(kubectl get svc knative-ingressgateway --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
	```

-	Find the URL of your service (and export it as a system variable):

	```
	kubectl get services.serving.knative.dev helloworld-go  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
	export HOST_URL=$(kubectl get services.serving.knative.dev helloworld-go  --output jsonpath='{.status.domain}')
	```

-	Request the app and see the results:

```shell
curl -H "Host: ${HOST_URL}" http://${IP_ADDRESS}
Hello World: Go Sample v1!
```

*Based on the official [Knative documentation](https://github.com/knative/docs/blob/master/serving/samples/helloworld-go/README.md), licensed under the [Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/), and code samples are licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0)*

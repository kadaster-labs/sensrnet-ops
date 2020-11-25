# SensRNet Operations

This repository contains all operations steps and scripts needed to operate the Kubernetes environments on which the application will run.

- [SensRNet Operations](#sensrnet-operations)
  - [Prerequisites](#prerequisites)
- [Set up the environment](#set-up-the-environment)
  - [Clone repositories](#clone-repositories)
  - [Local development](#local-development)
    - [Using Docker Desktop](#using-docker-desktop)
    - [Using Kubernetes](#using-kubernetes)
  - [AKS](#aks)
  - [Secrets](#secrets)
- [Deploy registry node components](#deploy-registry-node-components)
  - [Initialization](#initialization)
  - [Secret management](#secret-management)
  - [Monitoring](#monitoring)
  - [The Sensrnet application](#the-sensrnet-application)
  - [Work log](#work-log)

## Prerequisites
- **An Azure account** 
  It is assumed that you have an [Azure](https://azure.microsoft.com/en-us/) account with the right permissions to create an [AKS cluster](https://azure.microsoft.com/en-us/services/kubernetes-service/).
- **Azure CLI** The Azure CLI is necessary for interaction with Azure from the command line.
- **Git** git is required for checking out the source code. We recommend [Git Bash](https://gitforwindows.org/) for Windows as it also satisfies the next point.
- **A Bash shell** Most of the script used for handling secrets are written in bash. You can use Mac, Linux or tools for Windows like Git Bash or [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
- **kubectl & kustomize CLI's** The [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) command line tools are required to interact and deploy to Kubernetes clusters. 

# Set up the environment
## Clone repositories
Clone all repos by running the `clone_all_repos.sh` script directly on your command line. The contents of the file can be inspected [here](
  https://github.com/kadaster-labs/sensrnet-ops/blob/master/clone_all_repos.sh). The script clones all repositories related to Sensrnet to the current folder.

```bash
$ curl -s -L https://raw.githubusercontent.com/kadaster-labs/sensrnet-ops/master/clone_all_repos.sh | bash
```
*Note: We strongly recommend to first inspect the content of scripts from remote sources.*

## Local development
As the application is built using Docker containers, it can be run in any container runtime. 
### Using Docker Desktop
It is possible to run all code locally for development purposes with [Docker Desktop](https://www.docker.com/products/docker-desktop), using Docker Compose. Each repository contains a `docker-compose.yaml` file. Each component can then be lifted by running `docker-compose up`.

### Using Kubernetes
To also see how the components work within a Kubernetes cluster (just as it will run in the cloud), you can install Kubernetes locally and deploy there. Kubernetes can be run in Docker and is provided [by default](https://www.docker.com/products/kubernetes) with a Docker Desktop installation. The cluster will then be named `docker-desktop`. Please note that Kubernetes in Docker does not contain a metrics server.

A popular alternative is [minikube](https://kubernetes.io/docs/tasks/tools/), which provides a fully-featured Kubernetes cluster.

## AKS
First make sure that you're logged in to your Azure account on the command line.
```bash
$ az login
```

Then, create an AKS cluster if you haven't done so.
```bash
# (Optional) if you are member of multiple Azure subscriptions, make sure you set the tool to operate in the right one
$ az account set --subscription $SUBSCRIPTION

# Create a resource group in which the AKS cluster will reside.
$ az group create --name $RESOURCE_GROUP --location westeurope
```

Lastly, the credentials to connect to the AKS cluster are required by the Kubernetes CLI. The connection details can be saved to the `~/.kube/config` using the following command, where $CLUSTER_NAME is the name of the cluster as defined in Azure and $RESOURCE_GROUP the resource group in which the cluster resides.
```bash
# Create the AKS cluster
$ az aks create --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --generate-ssh-keys
```

## Secrets
Credentials are _never_ committed directly into this repo (or any!) but are stored in the [GPG](https://www.if-not-true-then-false.com/2010/linux-encrypt-files-decrypt-files-gpg-interactive-non-interactive/) file: `secrets/secrets.json.gpg` (within Kadaster, it contains a symbolic link to git repo for bookkeeping)

If you haven't got an encrypted secrets file yet, or want to decrypt the current one, run (after populating/updating `secrets.json`):
```bash
$ ./secrets.sh encrypt secrets/secrets.json <PASSPHRASE>
```
The example file `secrets.json` is provided in this repository. It is highly recommended that you set your own values in this value.

The file can then be decrypted with:
```bash
$ ./secrets.sh decrypt ../secrets/secrets.json.gpg <PASSPHRASE>
```

# Deploy registry node components

## Initialization
Before any images can be deployed on the created cluster, we'll assume that you have the encrypted secrets file.

Since each secret will live in the same namespace as the pod that'll use them, we'll have to first create the namespaces.
```bash
$ kubectl apply -f namespaces.yaml
```

## Secret management
Once the namespaces have been created in the Kubernetes cluster, we can then deploy the secrets.
```bash
python deployAllSecrets.py --inputfile <jsonfile> --cluster <cluster>
```

The secrets should now have been deployed successfully. You can check if they are created by inspecting:
```bash
$ kubectl get secrets -A
```

See [Secrets](#Secrets) on how to update and store the secrets file locally. Every time you update the secrets, you have to rerun these steps.

## Monitoring
Now that the namespaces and secrets are available, we can deploy the monitoring stack. We make use of Prometheus + Grafana for monitoring and the ELK stack for logging.
```bash
$ kustomize build monitoring/overlays/test | kubectl apply -f -
```

## The Sensrnet application
The rest of the deployments can proceed as regular. The deployment files for each component can be built using Kustomize in their respective folders and deployed. Please note: whenever a namespace is recreated, the corresponding secrets would be have to redeployed first.

For each of the source code repos, run:
```bash
$ kustomize build deployment/overlays/(prod|test|local) | kubectl apply -f -
```

## Work log

On localhost:

```bash
$ kubectl config use-context docker-desktop
```

Init Kadaster PLS AKS test cluster:

```bash
$ az login
# set default subscription (if not already set properly)
$ az account set --subscription "etc-test"
# get credentials
$ ./ops.sh get-credentials -c <cluster-name> -p <passphrase (of secrets.json.gpg)>
```

Get credentials for `gemeente-a`, `gemeente-b` and `viewer` clusters:

```bash
$ ./ops.sh get-credentials -p $SENSRNET_PASSPHRASE -c sensrnet-gemeente-a -e labs_test

$ ./ops.sh get-credentials -p $SENSRNET_PASSPHRASE -c sensrnet-gemeente-b -e labs_test

$ ./ops.sh get-credentials -p $SENSRNET_PASSPHRASE -c sensrnet-viewer -e labs_test
```

Select Kadaster PLS AKS test cluster:

```bash
$ ./ops.sh use-cluster -c <cluster-name>
```

Create new AKS Kafka cluster:

```bash


$ az aks get-credentials --resource-group sensrnet-kafka-2 --name sensrnet-aks-kafka-2

$ kubectl config use-context sensrnet-aks-kafka-2
```


Deployment using [strimzi](https://itnext.io/kafka-on-kubernetes-the-strimzi-way-part-2-43192f1dd831)

```bash
$ kubectl get configmap/my-kafka-cluster-kafka-config -o yaml > my-kafka-cluster.config.json

$ export CLUSTER_NAME=my-kafka-cluster
$ kubectl get secret $CLUSTER_NAME-cluster-ca-cert -o jsonpath='{.data.ca\.crt}' | base64 --decode > ca.crt
$ kubectl get secret $CLUSTER_NAME-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 --decode > ca.password

$ kubectl get service/${CLUSTER_NAME}-kafka-external-bootstrap --output=jsonpath={.status.loadBalancer.ingress[0].ip}
```

Deploy secrets - in this case: `kafka-ca`

```bash
$ ./ops.sh use-cluster -c sensrnet-gemeente-a -e labs_test

$ ./deploySecret.sh kafka-ca ../secrets/ca.crt.gpg ../secrets/ca.password.gpg -p $SENSRNET_PASSPHRASE
```

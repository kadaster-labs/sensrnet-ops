# SensRNet Operations

This repo contains all operations 'stuff' needed to operate the environments @ Kadaster.

## Secrets

Credentials are _never_ committed directly into this repo (or any!) but are stored in the [GPG](https://www.if-not-true-then-false.com/2010/linux-encrypt-files-decrypt-files-gpg-interactive-non-interactive/) file: `secrets.json.gpg`

Decrypt with:

```bash
$ ./secrets.sh decrypt secrets.json.gpg <PASSPHRASE>
```

Encrypt new secrets (after updating `secrets.json`) with:

```bash
$ ./secrets.sh encrypt secrets.json <PASSPHRASE>
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
$ az account set --subscription sensrnet

$ az group create --name sensrnet-kafka-2 --location westeurope

$ az aks create --resource-group sensrnet-kafka-2 --name sensrnet-aks-kafka-2 --node-count 1 --enable-addons monitoring --generate-ssh-keys

$ az aks get-credentials --resource-group sensrnet-kafka-2 --name sensrnet-aks-kafka-2

$ kubectl config use-context sensrnet-aks-kafka-2
```

```bash
$ ./kust.sh apply -f kafka -e test

$ kubectl -n kafka get all

5b5621aa-64e5-4b63-a3a0-a5951c0e6bda
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

$ ./deploySecret.sh kafka-ca ca.crt.gpg ca.password.gpg -p $SENSRNET_PASSPHRASE
```

## Local Dev Env

```bash
$ scoop install kustomize
```

## Deploy Kustomize 'packages'

```bash
# deploy on localhost
$ kubectl config use-context docker-desktop

$ ./kust.sh apply -f kafka -e local

$ kubectl -n kafka get all
```

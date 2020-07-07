# SensRNet Operations

This repo contains all operations 'stuff' needed to operate the environments @ Kadaster.

## URIs

| Name   | URI                                                    | Environment |
|--------|--------------------------------------------------------|-------------|
| Kafka1 | kafka1zs4ud5fbws3us-vm0.westeurope.cloudapp.azure.com | labs_test   |



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
```

> // TODO deploy kafka ([tutorial](https://portworx.com/run-ha-kafka-azure-kubernetes-service/)) and zookeeper ([tutorial](https://kubernetes.io/docs/tutorials/stateful-application/zookeeper/))

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

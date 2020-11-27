# SensRNet Operations

This repo contains all operations 'stuff' needed to operate the environments @ Kadaster.

## Local Dev Env

Clone all repos by running the `clone_all_repos.sh` script directly on your command line:

```bash
$ curl -s -L https://raw.githubusercontent.com/kadaster-labs/sensrnet-ops/master/clone_all_repos.sh | bash
```

Install Kustomize to apply kustomization of the configuration ;-)

```bash
$ scoop install kustomize
```

## Secrets

Credentials are _never_ committed directly into this repo (or any!) but are stored in the [GPG](https://www.if-not-true-then-false.com/2010/linux-encrypt-files-decrypt-files-gpg-interactive-non-interactive/) file: `../secrets/secrets.json.gpg` (where `../secrets` is a private cloned git repo)

Decrypt with:

```bash
$ ./secrets.sh decrypt ../secrets/secrets.json.gpg <PASSPHRASE>
```

Encrypt new secrets (after updating `secrets.json`) with:

```bash
$ ./secrets.sh encrypt ../secrets/secrets.json <PASSPHRASE>
```

## Monitoring
Before deploying the monitoring stack, first decode the admin credentials. 
```
./secrets.sh decrypt ../secrets/grafana-admin-user.gpg <PASSPHRASE> > monitoring/overlays/test/grafana/admin-user.secret
./secrets.sh decrypt ../secrets/grafana-admin-password.gpg <PASSPHRASE> > monitoring/overlays/test/grafana/admin-password.secret
```

Then, proceed as normal.
```
kustomize build monitoring/overlays/test | kubectl apply -f -
```


## Deploy registry node components

### Initialization
Before any images can be deployed on the created cluster, we'll assume that you have a (decrypted) JSON secrets file set. The example file `secrets.json` is provided in this repository. It is highly recommended that you set your own values in this value.

Since each secret will live in the same namespace as the pod that'll use them, we'll have to first create the namespaces.
```bash
$ kubectl apply -f namespaces.yaml
```

Once the namespaces have been created in the Kubernetes cluster, we can then deploy the secrets.
```bash
python deployAllSecrets.py --inputfile <jsonfile> --cluster <cluster>
```

The secrets should now have been deployed successfully. You can check if they are created by inspecting:
```bash
$ kubectl get secrets -A
```

### Deployment
The rest of the deployments can proceed as regular. The deployment files for each component can be built using Kustomize in their respective folders and deployed. Please note: whenever a namespace is recreated, the corresponding secrets would be have to deployed first.

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

$ ./deploySecret.sh kafka-ca ../secrets/ca.crt.gpg ../secrets/ca.password.gpg -p $SENSRNET_PASSPHRASE
```

## Find Us

* [GitHub](https://github.com/kadaster-labs/sensrnet-home)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Maintainers <a name="maintainers"></a>

Should you have any questions or concerns, please reach out to one of the project's [Maintainers](./MAINTAINERS.md).

## License

This work is licensed under a [EUPL v1.2 license](./LICENSE.md).

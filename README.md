# SensRNet Operations

This repo contains all operations 'stuff' needed to operate the environments @ Kadaster.

Credentials are _never_ committed directly into this repo (or any!) but are stored in the [GPG](https://www.if-not-true-then-false.com/2010/linux-encrypt-files-decrypt-files-gpg-interactive-non-interactive/) file: `secrets.json.gpg`

Decrypt with:

```bash
$ ./secrets.sh decrypt <PASSPHRASE>
```

Encrypt new secrets (after updating `secrets.json`) with:

```bash
$ ./secrets.sh encrypt <PASSPHRASE>
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
$ ./ops.sh select-cluster -c <cluster-name>
```


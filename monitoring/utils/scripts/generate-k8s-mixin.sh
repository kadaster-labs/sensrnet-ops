#!/bin/bash

# Generate K8S-mixin dashboards, alerts and rules
jsonnet -J ./kubernetes-mixin-release-0.1  -J ./kubernetes-mixin-release-0.1/vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusAlerts)' > ./alerts/alerts-k8s-mixin.yaml
jsonnet -J ./kubernetes-mixin-release-0.1 -J ./kubernetes-mixin-release-0.1/vendor -S -e 'std.manifestYamlDoc((import "mixin.libsonnet").prometheusRules)' > ./rules/rules-k8s-mixin.yaml
jsonnet -J ./kubernetes-mixin-release-0.1 -J ./kubernetes-mixin-release-0.1/vendor -m ./dashboards -e '(import "mixin.libsonnet").grafanaDashboards'

# azure-monitoring

Prometheus and related components that are used are explained below:

![Prometheus overview](/prometheus_kubernetes_diagram_overview.png)


1 – The Prometheus server(s) can be configured to use auto discovery to pull metrics from predfined (Prometheus-aware) resources (by **scrape-configs** in the Prometheus configuration)  

2 – Besides application metrics, we want Prometheus to collect metrics related to the Kubernetes services, nodes and orchestration status:  

- for host-related metrics: cpu, mem, network, etc. the **'node exporters'** are deployed and scrape-config is added

- for orchestration and cluster level metrics: deployments, pod metrics, resource reservation, etc., **'kube-state-metrics'** is deployed and scrape-config is added

- for Kube-system metrics from internal components: apiserver, kubelet, etcd, dns, scheduler, etc. scrape-configs are added in Prometheus configuration  

3 – Prometheus can configure rules to trigger alerts using PromQL and 'alertmanager'is deployed for managing alert notification, grouping, inhibition, etc.  

4 – The alertmanager component configures the receivers, gateways to deliver alert notifications.  

5 – Grafana can pull metrics from any number of Prometheus servers and display panels and Dashboards.  

# Initial actions

#### Namespace:  

- Create 'monitoring' namespace:  
    ```kubectl create ns monitoring```  
#### Grafana:  

- Create secret for Grafana:  
    ```kubectl create secret generic rec-monitoring-grafana --from-literal=admin-user=admin --from-literal=admin-password=<password> -n monitoring```

- Create, if not already present, an AzureDisk for Grafana via PLS SelfservicePortal (https://pls.test.kadaster.nl/selfservice/)  

#### Prometheus/Alertmanager:  

- Create, if not already present, a StorageAccount for Prometheus/Alertmanager via PLS SelfservicePortal (https://pls.test.kadaster.nl/selfservice/)  
 
- Create a secret with storage-account credentials on aks-cluster to be used in Prometheus and Alertmanager:  
        ```kubectl create secret generic monitoring-storage-account --from-literal=azurestorageaccountname=sa<resourcename> --from-literal=azurestorageaccountkey=<sa-password> -n monitoring```

- Create, if not already present, in Azure Storage Explorer 2 fileshares under storage-account:
    - prometheus  
    - alertmanager

#### Azure Disk storage

- Create an Azure Disk for Prometheus. Current settings only stores 7 days of data so make the disk the minimum size (32 GB). Storage does not need to be fast so use "Standard-HDD".
  When created, make sure you write down the ResourceId somewhere, you will later need this to link the DiskURI inside the overlay.

- Create an Azure Disk for Grafana. Current settings only stores 14 days of data so make the disk the minimum size (32 GB). Storage does not need to be fast so use "Standard-HDD".
  When created, make sure you write down the ResourceId somewhere, you will later need this to link the DiskURI inside the overlay.

# Create/add/modify Grafana dashboards and Prometheus alerts/rules

In the directory ```utils``` there are subdirectories for (Grafana-) dashboards and (Prometheus-) alerts/rules.  In the dashboard-subdirectory the dashboard json-files needs to be (re)placed/modified and in the alerts/rules subdirectories the specific alerts/rules yaml-files need to be (re)placed/modified:  
```
-rw-rw-rw- 1 vuykh vuykh 20530 Sep  9 11:14 ./alerts/alerts-k8s.yaml
-rw-rw-rw- 1 vuykh vuykh 26422 Sep  6 13:30 ./dashboards/k8s-cluster-rsrc-use.json
-rw-rw-rw- 1 vuykh vuykh 26293 Sep  6 13:30 ./dashboards/k8s-node-rsrc-use.json
-rw-rw-rw- 1 vuykh vuykh 44374 Sep  6 13:30 ./dashboards/k8s-resources-cluster.json
-rw-rw-rw- 1 vuykh vuykh 29108 Sep  6 13:30 ./dashboards/k8s-resources-namespace.json
-rw-rw-rw- 1 vuykh vuykh 31178 Sep  6 13:30 ./dashboards/k8s-resources-pod.json
-rw-rw-rw- 1 vuykh vuykh 30665 Sep  6 13:30 ./dashboards/k8s-resources-workload.json
-rw-rw-rw- 1 vuykh vuykh 31881 Sep  6 13:30 ./dashboards/k8s-resources-workloads-namespace.json
-rw-rw-rw- 1 vuykh vuykh 41154 Sep  6 13:30 ./dashboards/nodes.json
-rw-rw-rw- 1 vuykh vuykh 16180 Sep  6 13:30 ./dashboards/persistentvolumesusage.json
-rw-rw-rw- 1 vuykh vuykh 18935 Sep  6 13:30 ./dashboards/pods.json
-rw-rw-rw- 1 vuykh vuykh 27240 Sep  6 13:30 ./dashboards/statefulset.json
-rw-rw-rw- 1 vuykh vuykh 13901 Sep  9 11:14 ./rules/rules-k8s.yaml  
```  

To merge and place the dashboards/alerts/rules in the correct directories for kustomzie to pick them up, run script ```./scripts/generate-custom-files.sh```  from ```./utils```.


To direct kustomize to convert the required alerts/dashboards and rules in configMap-yamls, specify the files in the Grafana and Prometheus kustomization-file under the stanza ```configMapGenerator```  in ```./base/grafana|prometheus/kustomization.yaml```

Now you can (re)deploy your stack or specific application and test it, f.i.:  

```kubectl kustomize ./overlays/test/ | k apply -f -```   or  
```kubectl kustomize ./overlays/test/prometheus/ | k apply -f - ```   

REMARK:  
Because Kubernetes ConfigMap-objecst are limited in size the dashboard json-files are first "compressed". These 'compressed' json-files are generated by ```./scripts/generate-custom-files.sh```  

# K8S-monitoring - start  

As a start for K8S-monitoring a consistent set of rules/alert and dashboards called *kubernets-mixin* is used (see https://github.com/kubernetes-monitoring/kubernetes-mixin)
In utils subdirectory ./kubernetes-mixin-release-01 (for K8S < v1.14) this repo/branch is included and in config-file ```./kubernetes-mixin-release-0.1/config.libsonnet``` settings can be modified. To (re)generate the K8S dashboards/alerts/rules simply run ```./scripts/generate-k8s-mixin.sh``` from ```./utils```.  (for more details on prerequisites ((like jsonnet/jb/json2yaml) see: https://github.com/kubernetes-monitoring/kubernetes-mixin/blob/master/README.md).  

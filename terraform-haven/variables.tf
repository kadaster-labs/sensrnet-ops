variable "clustername" {
  description = "The name of the cluster"
  default = "haven"
}

variable "location" {
  description = "The Azure Region in which all resources should be provisioned"
  default = "westeurope"
}

variable "private_cluster_enabled" {
  description = "Make the cluster private (do not publicly expose Kubernetes API)"
  default = false
}

variable "node_count" {
  description = "The number of nodes in the default node pool"
  default = "3"
}

variable "node_size" {
  description = "The size of the nodes in the default node pool"
  default = "Standard_DS2_v2"
}

variable "priority" {
  description = "The priority of the nodes (Regular or Spot)"
  default = "Regular"
}

variable "max_pods" {
  description = "The number of maximum pods on each node"
  default = 110
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling"
  default = false
}

variable "auto_scaling_min_count" {
  description = "The minumum number of nodes when using auto scaling"
  default = 3
}

variable "auto_scaling_max_count" {
  description = "The maximum number of nodes when using auto scaling"
  default = 5
}

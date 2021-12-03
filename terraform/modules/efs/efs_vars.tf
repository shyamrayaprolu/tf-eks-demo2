variable "efs_name" {}
variable "subnets_count" {}
variable "efs_subnets" {
  type = list
}
variable "efs_security_group" {
  type = list
}
variable "kubernetes_cluster_name" {}
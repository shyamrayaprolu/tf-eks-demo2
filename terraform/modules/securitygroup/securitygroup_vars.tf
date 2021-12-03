variable "kubernetes_cluster_name" {}
variable "vpc_id" {}
variable "securitygroup_name" {}
variable "securitygroup_description" {}
variable "sg_depends_on" {
  type    = any
  default = null
}

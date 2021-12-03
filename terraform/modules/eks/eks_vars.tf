variable "template_file" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "cluster_subnets" {
  type = list
}
variable "cluster_iam_role" {}
variable "master_securitygroup_ids" {}
variable "worker_security_groups" {
  type = list
}

variable "cluster_log_types" {
    type = list
}
variable "ec2_instance_type" {}
variable "iam_instance_profile_name" {}
variable "ami_id" {}
variable "ec2_keyname" {}
variable "ec2_mincluster_size" {}
variable "ec2_maxcluster_size" {}
variable "ec2_desiredcluster_size" {}
variable "ec2_volume_type" {}
variable "ec2_volume_size" {}
variable "health_check_type" {}
variable "health_check_grace_period" {}
variable "ec2_subnets" {
  type = list
}

variable "kubernetes_cluster_name" {}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "ekscluster_depends_on" {
  type    = any
  default = null
}
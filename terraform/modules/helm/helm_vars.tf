variable "cluster_name" {}
variable "cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "cluster_auth_token" {}
variable "aws_region" {}
variable "helm_depends_on" {
  type    = any
  default = null
}



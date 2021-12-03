#provider specific config variables when using IAM credentials (For Local Testing using SSO Generator)
# variable "credpath" {}
variable "aws-profile" {}
variable "aws-region" {}
variable "environment" {}
variable "account_id" {}
variable "stack_val" {}
variable "subsystem_val" {}

variable "vpc_name" {}
variable "vpc_cidr" {}
variable "availability_zones" {
  type = list
}
variable "private_subnets" {
    type = list
}
variable "public_subnets" {
    type = list
}
variable "kubernetes_cluster_name" {}

# variable "vpc_id" {}
# variable "ext_subnet_id1" {}
# variable "ext_subnet_id2" {}
# variable "ext_subnet_id3" {}
# variable "int_subnet_id1" {}
# variable "int_subnet_id2" {}
# variable "int_subnet_id3" {}
# variable "int_subnet_ids" {
#   default = []
# }
# variable "ext_subnet_ids" {
#   default = []
# }


#eks cluster variables
variable "cluster_version" {}
variable "cluster_log_types" {}

#security group variables
# variable "cidr" {}
variable "workstation_cidr" {}


# #ec2 launch config variables
variable "ami_id" {}
variable "ec2_instance_type" {}
variable "ec2_volume_type" {}
variable "ec2_volume_size" {}
variable "ec2_ssh_key" {}

# #ec2 asg variables
variable "ec2_mincluster_size" {}
variable "ec2_maxcluster_size" {}
variable "ec2_desiredcluster_size" {}
variable "health_check_type" {}
variable "health_check_grace_period" {}

#bastion host variables
# variable "bastion_securitygroup_id" {}

#aws-auth config variables
variable "aws_accounts" {}
variable "aws_roles" {}
variable "aws_users" {}
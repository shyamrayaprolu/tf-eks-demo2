data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  load_config_file       = false
}


data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "aws_current" {
}

data "template_file" "eks_userdata" {
  template =   var.template_file
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = var.vpc_id
  # The private AND public subnet ids
  subnets                         = var.cluster_subnets
  # Modify these to control cluster access
  cluster_endpoint_private_access = "false"
  cluster_endpoint_public_access  = "true"
  #cluster_endpoint_public_access_cidrs = var.public_access_cidrs
    # Makes configuring aws-iam-authenticator easy
  write_kubeconfig                = true
  # Change to wherever you want the generated kubeconfig to go
  # config_output_path              = "./"
  manage_aws_auth                 = true
  #write_aws_auth_config          = true
  manage_cluster_iam_resources    = false
  manage_worker_iam_resources     = false
  cluster_iam_role_name           = var.cluster_iam_role
  cluster_create_security_group   = false
  cluster_security_group_id       = var.master_securitygroup_ids
  cluster_enabled_log_types       = var.cluster_log_types
#   cluster_encryption_config = [
#     {
#       provider_key_arn = aws_cloudformation_stack.eks-volume-kms.outputs[var.cfn_keyid_output]
#       resources        = ["secrets"]
#     }
#   ]
  tags = {
    "terraform"       = "true"
    "kubernetes.io/cluster/${var.kubernetes_cluster_name}" = "owned"
  }
  
  worker_groups = [
    {
      name                          = "worker"
      instance_type                 = var.ec2_instance_type
      key_name                      = var.ec2_keyname
      asg_min_size                  = var.ec2_mincluster_size
      asg_desired_capacity          = var.ec2_desiredcluster_size
      asg_max_size                  = var.ec2_maxcluster_size
      root_volume_size              = var.ec2_volume_size
      root_volume_type              = var.ec2_volume_type
      additional_userdata           = data.template_file.eks_userdata.rendered
      subnets                       = var.ec2_subnets
      ami_id                        = var.ami_id
      enable_monitoring             = false
      worker_create_initial_lifecycle_hooks = true
      iam_instance_profile_name     = var.iam_instance_profile_name
      additional_security_group_ids = var.worker_security_groups
      health_check_grace_period     = var.health_check_grace_period
      health_check_type             = var.health_check_type
      tags = [
        {
          "key"                 = "kubernetes.io/cluster/${var.kubernetes_cluster_name}"
          "value"               = "owned"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "terraform"
          "value"               = "true"
          "propagate_at_launch" = true
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.kubernetes_cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },

  ]
  worker_additional_security_group_ids = var.worker_security_groups
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
  depends_on                           = [var.ekscluster_depends_on]
}



output "cluster_endpoint" {
  value       = data.aws_eks_cluster.cluster.endpoint
}
output "cluster_certificate_authority_data" {
  value       = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}
output "cluster_auth_token" {
  value       = data.aws_eks_cluster_auth.cluster_auth.token
}
output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}
output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}
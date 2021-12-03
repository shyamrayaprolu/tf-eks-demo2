module "eks_vpc" {
  source                   = "./modules/vpc"
  vpc_name                 = var.vpc_name
  cidr                     = var.vpc_cidr
  availability_zones       = var.availability_zones
  private_subnets          = var.private_subnets
  public_subnets           = var.public_subnets
  kubernetes_cluster_name  = var.kubernetes_cluster_name
  environment              = var.environment
}

module "eks_master_role" {
  source                   = "./modules/iamrole"
  iam_role_name            = "${var.stack_val}-${var.environment}-${var.subsystem_val}-eksmaster"
  iam_assume_role_filename = "assumerole-eksmaster-trusted-entities.json"
  iam_role_policy_name     = "${var.stack_val}-${var.environment}-${var.subsystem_val}-eksmaster"
  iam_role_policy_filename = "assumerole-eksmaster-policy.json"
  managed_policies         = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy","arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]
}

module "eks_worker_role" {
  source                   = "./modules/iamrole"
  iam_role_name            = "${var.stack_val}-${var.environment}-${var.subsystem_val}-eksworker"
  iam_assume_role_filename = "assumerole-eksworker-trusted-entities.json"
  iam_role_policy_name     = "${var.stack_val}-${var.environment}-${var.subsystem_val}-eksworker"
  iam_role_policy_filename = "assumerole-eksworker-policy.json"
  managed_policies         = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy","arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy","arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

module "eks_worker_instprofile" {
  source                    = "./modules/iaminstanceprofile"
  iam_role_name             = "${var.stack_val}-${var.environment}-${var.subsystem_val}-eksworker"
  iam_instance_profile_name = "${var.stack_val}-${var.environment}-${var.subsystem_val}-instprofile"
  iaminstprofile_depends_on = [module.eks_worker_role]
}

module "master_securitygroup" {
  source                    = "./modules/securitygroup"
  securitygroup_name        = "${var.stack_val}-${var.environment}-${var.subsystem_val}-master-sg"
  securitygroup_description = "Cluster communication with worker nodes"
  vpc_id                    = module.eks_vpc.vpc_id
  kubernetes_cluster_name   = "${var.stack_val}-${var.environment}-${var.subsystem_val}-ekscluster"
  sg_depends_on             = [module.eks_vpc]
}

module "worker_securitygroup" {
  source                    = "./modules/securitygroup"
  securitygroup_name        = "${var.stack_val}-${var.environment}-${var.subsystem_val}-worker-sg"
  securitygroup_description = "Security group for all nodes in the cluster"
  vpc_id                    = module.eks_vpc.vpc_id
  kubernetes_cluster_name   = "${var.stack_val}-${var.environment}-${var.subsystem_val}-ekscluster"
  sg_depends_on             = [module.eks_vpc]
}

module "master_securitygroup_rule1" {
  source          = "./modules/securitygroupidrule"
  sg_description  = "Allow pods to communicate with the cluster API Server"
  type            = "ingress"
  from_port       = "443"
  to_port         = "443"
  protocol        = "tcp"
  source_sg_id    = module.worker_securitygroup.sg_id
  sg_id           = module.master_securitygroup.sg_id
}

module "master_securitygroup_rule2" {
  source          = "./modules/securitygroupidrule"
  sg_description  = "Allow self communication with in master"
  type            = "ingress"
  from_port       = "0"
  to_port         = "0"
  protocol        = "-1"
  source_sg_id    = module.master_securitygroup.sg_id
  sg_id           = module.master_securitygroup.sg_id
}

module "master_securitygroup_rule3" {
  source         = "./modules/securitygrouprule"
  sg_description = "Allow workstation or EC2 to communicate with the cluster API Server"
  type           = "ingress"
  from_port      = "443"
  to_port        = "443"
  protocol       = "tcp"
  cidr           = var.workstation_cidr
  sg_id          = module.master_securitygroup.sg_id
}



module "worker_securitygroup_rule1" {
  source          = "./modules/securitygroupidrule"
  sg_description  = "Allow node to communication with each other and self"
  type            = "ingress"
  from_port       = "0"
  to_port         = "65535"
  protocol        = "-1"
  source_sg_id    = module.worker_securitygroup.sg_id
  sg_id           = module.worker_securitygroup.sg_id
}

module "worker_securitygroup_rule2" {
  source          = "./modules/securitygroupidrule"
  sg_description  = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  type            = "ingress"
  from_port       = "1025"
  to_port         = "65535"
  protocol        = "tcp"
  source_sg_id    = module.master_securitygroup.sg_id
  sg_id           = module.worker_securitygroup.sg_id
}

# module "worker_securitygroup_rule3" {
#   source         = "./modules/securitygroupidrule"
#   sg_description = "Allow worker Kubelets and pods to receive communication from a standalone EC2 or local workstation"
#   type           = "ingress"
#   from_port      = "0"
#   to_port        = "65535"
#   protocol       = "tcp"
#   source_sg_id   = var.bastion_securitygroup_id
#   sg_id          = module.worker_securitygroup.sg_id
# }

module "eks_cluster" {
  source                    = "./modules/eks"
  # EKS Master Related Configs
  cluster_name              = "${var.stack_val}-${var.environment}-${var.subsystem_val}-ekscluster"
  cluster_version           = var.cluster_version
#   vpc_id                    = var.vpc_id
  vpc_id                    = module.eks_vpc.vpc_id
#   cluster_subnets           = var.ext_subnet_ids
  cluster_subnets           = module.eks_vpc.public_subnets
  cluster_iam_role          = module.eks_master_role.iam_role_output
  master_securitygroup_ids  = module.master_securitygroup.sg_id
  cluster_log_types         = var.cluster_log_types
  # EKS Worker Related Configs
  template_file             = file("template/userdata.sh.tpl")
  ec2_instance_type         = var.ec2_instance_type
  ec2_keyname               = var.ec2_ssh_key
  ec2_mincluster_size       = var.ec2_mincluster_size
  ec2_maxcluster_size       = var.ec2_maxcluster_size
  ec2_desiredcluster_size   = var.ec2_desiredcluster_size
  ec2_volume_type           = var.ec2_volume_type
  ec2_volume_size           = var.ec2_volume_size
#   ec2_subnets               = var.int_subnet_ids
  ec2_subnets               = module.eks_vpc.private_subnets
  ami_id                    = var.ami_id
  iam_instance_profile_name = "${var.stack_val}-${var.environment}-${var.subsystem_val}-instprofile"
  worker_security_groups    = [module.worker_securitygroup.sg_id]
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  kubernetes_cluster_name   = "${var.stack_val}-${var.environment}-${var.subsystem_val}-ekscluster"
  map_accounts              = var.aws_accounts
  map_roles                 = var.aws_roles
  map_users                 = var.aws_users
  ekscluster_depends_on     = [
    module.eks_vpc,
    module.eks_master_role, 
    module.eks_worker_role, 
    module.eks_worker_instprofile, 
    module.master_securitygroup, 
    module.worker_securitygroup
  ]
}

# module "exec" {
#   source                    = "./modules/localexec"
#   command                   = "mkdir ../../.kube;cp kubeconfig_* ../../.kube/config;ls -alt ../../.kube/config"
#   localexec_depends_on      = [module.eks_cluster]
# }

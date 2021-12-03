# Make sure to update the values mentioned in the anchor below
#provider specific config when using IAM credentials (For Local Testing using SSO Generator)
# credpath = "/Users/srayaprolu/.aws/credentials"
aws-profile = "default"
aws-region = "<aws-region>"
environment = "<environment>"
account_id = "<aws-account-no>"
stack_val = "aws"
subsystem_val = "demo2"

#vpc related config values
vpc_name = "eks-demo2-vpc"
vpc_cidr = "100.0.0.0/16"
availability_zones = ["<aws-region>-1a","<aws-region>-1b","<aws-region>-1c"]
private_subnets = ["100.0.1.0/24","100.0.2.0/24","100.0.3.0/24"]
public_subnets = ["100.0.101.0/24","100.0.102.0/24","100.0.103.0/24"]
kubernetes_cluster_name = "aws-<environment>-demo2-ekscluster"

#eks cluster configs
cluster_version = "1.19" # change the version to the latest version
cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# security group configs for security groups 
workstation_cidr = ["<Local Machine IP>"] # Put your local machine IP here

#ec2 launch configs
ami_id = "ami-00650807756050152" # change the AMI ID as per your requirement
ec2_instance_type = "t3a.medium"
ec2_volume_type = "gp2"
ec2_volume_size = "100"
ec2_ssh_key = "<ec2-keypair-name>"

#ec2 asg configs
ec2_mincluster_size = "2"
ec2_maxcluster_size = "6"
ec2_desiredcluster_size = "3"
health_check_type = "EC2"
health_check_grace_period = "0"

#bastion host configs
# bastion_securitygroup_id = "<for future use>"

#aws-auth configs
aws_accounts = ["<aws-account-no>"]
aws_roles = [{
      rolearn   = "arn:aws:iam::<aws-account-no>:role/<aws-iam-role>"
      username  = "system:node:{{EC2PrivateDNSName}}"
      groups    = ["system:masters"]
    },]
aws_users = [{
      userarn   = "arn:aws:iam::<aws-account-no>:user/<iam-user-1>"
      username  = "<iam-user-1>"
      groups    = ["system:masters"]
    },
    {
      userarn   = "arn:aws:iam::<aws-account-no>:user/<iam-user-2>"
      username  = "<iam-user-2>"
      groups    = ["system:masters"]
    },]
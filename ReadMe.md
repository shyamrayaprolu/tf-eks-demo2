# Overview: This repo is for setting up AWS EKS demo cluster using Terraform AWS Wrapper module. For more information please refer https://github.com/terraform-aws-modules/terraform-aws-eks

### !! Note :
#### 1. In this EKS Setup Control Plane is managed by AWS and Worker Nodes managed by User.
#### 2. VPC and Subnets are created automatically as part of this implementation.
#### 3. Make sure to install following cli tools upfront.
```Cancel changes
kubectl
terraform
helm
```
#### 4. Terraform AWS EKS Module will attach Worker nodes to EKS Cluster automatically. So we don't need to use helm.

## EKS Cluster Creation

### 1. Make sure to update `terraform/config.auto.tfvars` values as per your environment, Below are few important items to be updated.

Update the aws-auth configs in `terraform/config.auto.tfvars`
```
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
```

### 2. Make sure to update `terraform/backend.tf` values as per your environment
```
terraform {
  backend "s3" {
    region  = "<aws-region>"
    bucket  = "<aws-s3-bucket-name>"
    key     = "terraform/<environment>/terraform.tfstate"
    encrypt = true #AES-256 encryption
  }
}
```

### 3. Run `terraform init` as it will create a new backend

### 4. Run `terraform plan` to see the changes

### 5. Run `terraform apply` to apply the changes

### 6. Once the EKS cluster is created, run below command to create kubeconfig file
```
aws eks update-kubeconfig --name <eks-cluster-name> --kubeconfig ~/.kube/config --region <aws-region>
```
### 7. Test the EKS cluster access by running below command
```
kubectl get namespaces
```
### 8. Run below command to see the worker nodes joined to EKS cluster
```
kubectl get nodes
```

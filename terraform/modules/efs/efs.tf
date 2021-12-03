resource "aws_efs_file_system" "efs_main" {
  creation_token    = var.efs_name
  performance_mode  = "generalPurpose"
  throughput_mode   = "bursting"
  encrypted         = "true"
  
  tags = {
    "terraform"       = "true"
    "kubernetes.io/cluster/${var.kubernetes_cluster_name}" = "owned"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = var.subnets_count
  file_system_id  = aws_efs_file_system.efs_main.id
  subnet_id       = element(var.efs_subnets, count.index)
  security_groups = var.efs_security_group
}

output "mount_target_dns" {
  description = "Address of the mount target provisioned."
  value       = aws_efs_mount_target.efs_mount_target.0.dns_name
}
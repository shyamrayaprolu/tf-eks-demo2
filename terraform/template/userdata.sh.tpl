#!/bin/bash -xe

# Retrieve the necessary packages for `mount` to work
# properly with NFSv4.1
sudo yum update -y
sudo yum install -y amazon-efs-utils nfs-utils nfs-utils-lib


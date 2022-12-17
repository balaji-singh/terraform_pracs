To create an Amazon Elastic Container Service for Kubernetes (EKS) cluster using Terraform with the Calico network plugin, you can use the following steps:

Install and configure the AWS CLI and Terraform on your local machine.

Create a new Terraform configuration file, and specify the required provider and module dependencies. For example:

# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Load the EKS module from the Terraform Registry
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Set the desired EKS cluster configuration
  name                  = "my-eks-cluster"
  version               = "1.21"
  vpc_id                = "vpc-12345678"
  public_subnet_ids     = ["subnet-12345678", "subnet-23456789"]
  private_subnet_ids    = ["subnet-34567890", "subnet-45678901"]
  enable_irsa           = true
  irsa_identity_name    = "my-eks-cluster-admins"
  enable_alb_ingress    = true
  enable_alb_egress     = false
  enable_iam_roles      = true
  enable_api_server_mtls = false
  enable_fargate        = true
  enable_autoscaling    = true
  min_size              = 1
  max_size              = 10
  desired_capacity      = 5
  launch_template       = {
    id = "lt-0123456789abcdef"
  }
}

# Load the Calico module from the Terraform Registry
module "calico" {
  source = "terraform-aws-modules/calico/aws"

  # Set the desired Calico configuration
  cluster_name          = "my-eks-cluster"
  k8s_cluster_arn       = module.eks.k8s_cluster_arn
  vpc_id                = module.eks.vpc_id
  public_subnet_ids     = module.eks.public_subnet_ids
  private_subnet_ids    = module.eks.private_subnet_ids
  security_group_id     = module.eks.k8s_cluster_security_group_id
  bastion_security_group = module.eks.bastion_security_group_id
  instance_type         = "m4.large"
}


# Declare the input variables
inputs = {
  cluster_name       = var.cluster_name
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  availability_zones = var.availability_zones
  version            = var.kubernetes_version
}

# Create a module for the EKS cluster
module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"

  # Pass in the input variables as module arguments
  cluster_name       = inputs.cluster_name
  vpc_id             = inputs.vpc_id
  subnet_ids         = inputs.subnet_ids
  availability_zones = inputs.availability_zones
  version            = inputs.version

  # Other module arguments
  worker_groups = [
    {
      name              = "eks-workers"
      instance_type     = "t3.medium"
      desired_capacity  = 2
      max_size          = 2
      min_size          = 2
      ebs_volume_size   = 20
      cloudwatch_groups = ["eks-workers"]
    }
  ]

  # Enable IAM authentication for the EKS cluster
  enable_iam_authentication = true

  # Create a mapping of tag keys and values to apply to resources that support tagging
  tags = {
    Environment = "test"
  }
}

# In this example, the input variables (cluster_name, vpc_id, subnet_ids, availability_zones, and version) are declared at the top of the file and passed as arguments to the eks_cluster module. The module uses these variables to create an EKS cluster with the specified parameters.

# You can then use Terragrunt to manage the configuration and execution of this Terraform code. For example, you could create a separate Terragrunt configuration file for each environment (e.g. test, stage, prod) and use variable overrides to set the appropriate values for the input variables.

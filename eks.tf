# Specify the provider for Amazon Web Services
provider "aws" {
  region = "us-west-2"
}

# Create an IAM role for the EKS worker nodes
resource "aws_iam_role" "eks_worker_node_role" {
  name = "eks_worker_node_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the necessary policies to the IAM role
resource "aws_iam_policy_attachment" "eks_worker_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_policy_attachment" "eks_worker_node_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_policy_attachment" "eks_worker_node_policy_attachment_3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_role.name
}

# Create the EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks_worker_node_role.arn
}

# Create an Amazon EKS worker node group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.id
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
  subnet_ids = [
    "subnet-12345678",
    "subnet-87654321"
  ]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  ami_type       = "AL2_x86_64"
  instance_types = ["t3.small"]
  remote_access {
    ec2_ssh_key = "my-key-pair"
  }
  tags = {
    Name = "my-node-group"
  }
}

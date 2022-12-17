variable "cluster_name" {
  type    = string
  default = "my-eks-cluster"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "k8s_version" {
  type    = string
  default = "1.19"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 2
}

variable "calico_version" {
  type    = string
  default = "v3.17.1"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "eks_node_policy" {
  name = "${var.cluster_name}-node-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:ListUpdates"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "eks_node_policy_attachment" {
  name       = "${var.cluster_name}-node-policy-attachment"
  policy_arn = aws_iam_policy.eks_node_policy.arn
  roles      = [aws_iam_role.eks_node_role.name]
}

resource "aws_iam_instance_profile" "eks_node_profile" {
  name  = "${var.cluster_name}-node-profile"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_launch_configuration" "eks_node_launch_config" {
  name                 = "${var.cluster_name}-node-launch-config"
  image_id             = data.aws_ami.eks_worker_ami.

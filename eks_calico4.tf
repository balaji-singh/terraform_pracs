# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create the EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = "my-cluster"
  role_arn = "${aws_iam_role.eks_service_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks_cluster.id}"]
    subnet_ids        = ["${aws_subnet.eks_subnet.*.id}"]
  }
}

# Create the IAM role for the EKS service
resource "aws_iam_role" "eks_service_role" {
  name = "eks-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create the security group for the EKS cluster
resource "aws_security_group" "eks_cluster" {
  name   = "eks-cluster-sg"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the VPC and subnets for the EKS cluster
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_subnet" {
  count             = 2
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

# Fetch the list of available availability zones
data "aws_availability_zones" "available" {}

# Install the Calico network plugin
module "calico" {

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.58.0"

  cluster_name = "my-cluster"
  vpc_id       = var.vpc_id
  subnets      = var.subnets

  # Create a managed node group with the `aws-auth` and `kube-dns` addons
  create_node_group = true
  node_group_name   = "my-node-group"
  node_group_size   = 2
  node_group_ami    = "ami-0d5d9d301c853a04a"
  node_group_type   = "t3.medium"
  node_group_add_ons = [
    {
      "name" = "aws-auth"
      "config" = {
        "mapRoles" = [
          {
            "rolearn" = "arn:aws:iam::123456789012:role/EKSWorkerNodeRole"
            "username" = "system:node:{{EC2PrivateDNSName}}"
            "groups" = ["system:bootstrappers", "system:nodes"]
          }
        ]
      }
    },
    {
      "name" = "kube-dns"
      "enabled" = true
    }
  ]
}


# Create an EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  version  = "1.18"

  # Add worker nodes to the cluster
  # Replace the subnet IDs with the IDs of the subnets in your VPC
  vpc_config {
    subnet_ids = [
      "subnet-12345678",
      "subnet-87654321",
    ]
  }
}

# Enable the Kubernetes Dashboard addon for the EKS cluster
resource "aws_eks_cluster_addon" "dashboard" {
  cluster_name = aws_eks_cluster.my_cluster.name
  enabled      = true
  name         = "kubernetes-dashboard"
}

# Enable the AWS IAM Authenticator for the EKS cluster
resource "aws_eks_cluster_addon" "iam_authenticator" {
  cluster_name = aws_eks_cluster.my_cluster.name
  enabled      = true
  name         = "aws-iam-authenticator"
}


module "eks" {
  source = "terraform-aws-modules/eks/aws"

  name = "my-cluster"
  vpc_id = "vpc-123456"
  subnet_ids = ["subnet-123456", "subnet-789012"]
  instance_type = "t2.micro"
  desired_capacity = 2
  min_size = 1
  max_size = 2
  ssh_key_name = "my-key"
  service_role_arn = "arn:aws:iam::1234567890:role/EKS-Service-Role"

  tags = {
    Terraform = "true"
  }
}
module "eks" {
  # ... other configuration

  additional_user_data = [
    <<EOF
#!/bin/bash
cat <<EOF > /etc/eks/addons/aws-auth-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks.aws_iam_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
        EOF
    EOF
  ]
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.48.0"

  # Replace these values with your own
  cluster_name = "my-eks-cluster"
  vpc_id       = "vpc-12345678"
  subnets      = ["subnet-12345678", "subnet-87654321"]

  # Enable addons
  enable_alb_ingress_controller = true
  enable_appmesh_controller     = true
  enable_cluster_autoscaler     = true
  enable_cloudwatch_exporter    = true
  enable_fluentd                = true
  enable_prometheus_node_exporter = true
  enable_xray_daemon_set        = true

  # Add other configuration options as needed
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.48.0"

  # Replace these values with your own
  cluster_name = "my-eks-cluster"
  vpc_id       = "vpc-12345678"
  subnets      = ["subnet-12345678", "subnet-87654321"]

  # Add other configuration options as needed

  # Define the EBS volumes to use as persistent storage
  volume_groups = [
    {
      name              = "ebs-volume-1"
      volume_type       = "gp2"
      volume_size       = 100
      volume_iops       = 100
      encrypted         = true
      kms_key_id        = "arn:aws:kms:us-east-1:1234567890:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      delete_on_termination = true
    },
    {
      name              = "ebs-volume-2"
      volume_type       = "io1"
      volume_size       = 200
      volume_iops       = 200
      encrypted         = true
      kms_key_id        = "arn:aws:kms:us-east-1:1234567890:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      delete_on_termination = true
    },
  ]
}


provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "example" {
  name     = "example-cluster"
  role_arn = "${aws_iam_role.example.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.example.id}"]
    subnet_ids        = ["${aws_subnet.example.*.id}"]
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name = "${aws_eks_cluster.example.name}"
  node_group_name = "example-node-group"
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }
  instance_types = ["t3.medium"]
  ami_type = "AL2_x86_64"
  volume_size = 20
  subnet_ids = ["${aws_subnet.example.*.id}"]
  security_group_ids = ["${aws_security_group.example.id}"]
  remote_access {
    ec2_ssh_key = "${aws_key_pair.example.key_name}"
  }
  tags = {
    Name = "eks-node"
  }
}


resource "aws_eks_cluster" "example" {
  name     = "example"
  version  = "1.19"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    security_group_ids = [aws_security_group.example.id]
    subnet_ids        = data.aws_subnet_ids.example.ids
  }
}

resource "aws_iam_role" "example" {
  name               = "example"
  assume_role_policy = data.aws_iam_policy_document.example.json
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "example" {
  name   = "example"
  policy = data.aws_iam_policy_document.example.json
}
resource "aws_eks_addon" "ebs-csi-driver" {
  cluster_name = aws_eks_cluster.example.name
  name         = "ebs-csi-driver"
  enabled      = true
  config       = data.template_file.ebs-csi-driver.rendered
}

data "template_file" "ebs-csi-driver" {
  template = file("${path.module}/ebs-csi-driver.yaml")
}

# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Define the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = var.vpc_name
  }
}

# Define the subnets
resource "aws_subnet" "main" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-subnet-${count.index+1}"
  }
}

# Define the security groups
resource "aws_security_group" "main" {
  name        = var.security_group_name
  description = "Security group for the EKS cluster"
  vpc_id      = aws_vpc.main.id

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

  tags = {
    Name = var.security_group_name
  }
}

# Create the EBS CSI driver deployment
resource "kubernetes_deployment" "ebs_csi_driver" {
  metadata {
    name = "ebs-csi-driver"
  }

  spec {
    replicas = 1

    template {
      metadata {
        labels = {
          app = "ebs-csi-driver"
        }
      }

      spec {
        service_account_name = "ebs-csi-driver"
        containers {
          name  = "ebs-csi-driver"
          image = "amazon/aws-ebs-csi-driver:v1.3.0"
          args = [
            "--endpoint=$(ADDRESS)",
            "--v=5",
            "--timeout=5m",
          ]
          env {
            name  = "ADDRESS"
            value = "unix:/csi/csi.sock"
          }
          ports {
            container_port = 0
            host_port      = 0
          }
          volume_mounts {
            name      = "socket-dir"
            mount_path = "/csi"
          }
        }
        volumes {
          name      = "socket-dir"
          host_path {
            path = "/var/lib/kubelet/plugins/csi/socket"
          }
        }
      }
    }
  }
}

# Create the EBS CSI driver service
resource "kubernetes_service" "ebs_csi_driver" {
  metadata {
    name = "ebs-csi-driver"
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "ebs-csi-driver"
    }
    ports {
      port        = 0
      target_port = 0
    }
  }
}



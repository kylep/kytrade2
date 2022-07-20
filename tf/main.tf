terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ca-central-1"
}


resource "aws_iam_role" "kytrade2-EKS-Cluster-Role" {
  name = "kytrade2-EKS-Cluster-Role"
  path = "/"
  description = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
  # AmazonEKSVPCResourceControlle policy is optional, it allows Security Groups for Pods
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    Name = "kytrade2-EKS-Cluster-Role"
    app = "kytrade2"
  }
}

resource "aws_vpc" "kytrade2-VPC-Public" {
  cidr_block = "10.20.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  instance_tenancy = "default"
  tags = {
    Name = "kytrade2-VPC-Public"
    app = "kytrade2"
  }
}

resource "aws_subnet" "kytrade2-Subnet-Public-1" {
  vpc_id = aws_vpc.kytrade2-VPC-Public.id
  cidr_block = "10.20.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ca-central-1a"
  tags = {
    Name = "kytrade2-Subnet-Public-1"
    app = "kytrade2"
  }
}

resource "aws_subnet" "kytrade2-Subnet-Public-2" {
  vpc_id = aws_vpc.kytrade2-VPC-Public.id
  cidr_block = "10.20.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ca-central-1b"
  tags = {
    Name = "kytrade2-Subnet-Public-2"
    app = "kytrade2"
  }
}


resource "aws_eks_cluster" "kytrade2-EKS-Cluster" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
  name     = "kytrade2-EKS-Cluster"
  role_arn = aws_iam_role.kytrade2-EKS-Cluster-Role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.kytrade2-Subnet-Public-1.id,
      aws_subnet.kytrade2-Subnet-Public-2.id,
    ]
    endpoint_private_access = false  # EKS private API server endpoint is disabled
    endpoint_public_access = true  # EKS public API server endpoint is enabled
    public_access_cidrs = ["0.0.0.0/0",]  # CIDR blocks with access to public API endpoint
  }
  # version = ...  # TODO: Figure out version pinning to facilitate upgrades
  tags = {
    Name = "kytrade2-EKS-Cluster"
    app = "kytrade2"
  }
  kubernetes_network_config {
    service_ipv4_cidr = "10.21.0.0/16"
    ip_family = "ipv4"
  }
}

resource "aws_iam_role" "kytrade2-EKS-Node-Role" {
  name = "kytrade2-EKS-Node-Role"
  path = "/"
  description = "Role for EKS Nodes"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    Name = "kytrade2-EKS-Node-Role"
    app = "kytrade2"
  }
}

resource "aws_subnet" "kytrade2-Subnet-Node-1" {
  availability_zone = "ca-central-1a"
  cidr_block        = "10.20.4.0/22"  # 10.20.4.1 - 10.20.7.254
  vpc_id = aws_vpc.kytrade2-VPC-Public.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "kytrade2-Subnet-Node-1"
    app = "kytrade2"
    "kubernetes.io/cluster/${aws_eks_cluster.kytrade2-EKS-Cluster.name}" = "shared"
  }
}

resource "aws_subnet" "kytrade2-Subnet-Node-2" {
  availability_zone = "ca-central-1b"
  cidr_block = "10.20.8.0/22"  #	10.20.8.1 - 10.20.11.254
  vpc_id = aws_vpc.kytrade2-VPC-Public.id
  map_public_ip_on_launch = "true"
  tags = {
    Name = "kytrade2-Subnet-Node-2"
    app = "kytrade2"
    "kubernetes.io/cluster/${aws_eks_cluster.kytrade2-EKS-Cluster.name}" = "shared"
  }
}

/*
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "kytrade2-EKS-Node-Group" {
  cluster_name = aws_eks_cluster.kytrade2-EKS-Cluster.name
  node_group_name = "kytrade2-EKS-Node-Group"
  node_role_arn = aws_iam_role.kytrade2-EKS-Node-Role.arn
  disk_size = 25
  instance_types = ["t3.small"]
  remote_access {
    ec2_ssh_key = "Kyle"
  }
  ami_type = "AL2_x86_64"
  capacity_type = "SPOT"
  #subnet_ids = [
  #    aws_subnet.kytrade2-Subnet-Node-1.id,
  #    aws_subnet.kytrade2-Subnet-Node-2.id,
  #]
  subnet_ids = [
      aws_subnet.kytrade2-Subnet-Public-1.id,
      aws_subnet.kytrade2-Subnet-Public-2.id,
  ]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  tags = {
    Name = "kytrade2-EKS-Node-Group"
    app = "kytrade2"
  }
}

*/

output "endpoint" {
    value = aws_eks_cluster.kytrade2-EKS-Cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
    value = aws_eks_cluster.kytrade2-EKS-Cluster.certificate_authority[0].data
}

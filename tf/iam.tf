resource "aws_iam_role" "kytrade2-EKS-Cluster-Role" {
  name = "kytrade2-EKS-Cluster-Role"
  path = "/"
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


/*
# Error: failed creating IAM Role (kytrade2-EKS-ALB-Controller-Role): LimitExceeded: Cannot exceed quota for ACLSizePerRole: 2048
resource "aws_iam_role" "kytrade2-EKS-ALB-Controller-Role" {
  name = "kytrade2-EKS-ALB-Controller-Role"
  path = "/"
  description = "Role to allow ALB ingress and NLB services on EKS"
  assume_role_policy = file("${path.module}/eks-alb-nlb-controller-policy.json")
  tags = {
    Name = "kytrade2-EKS-ALB-Controller-Role"
    app = "kytrade2"
  }
}
*/

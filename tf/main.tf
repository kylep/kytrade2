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
  region  = "ca-central-1"
}

resource "aws_iam_role" "kytrade2-EKS-Cluster-Role" {
    arn                   = "arn:aws:iam::883546544043:role/kytrade2-EKS-Cluster-Role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "eks.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2022-06-12T20:21:40Z"
    description           = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."
    force_detach_policies = false
    id                    = "kytrade2-EKS-Cluster-Role"
    managed_policy_arns   = [
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    ]
    max_session_duration  = 3600
    name                  = "kytrade2-EKS-Cluster-Role"
    path                  = "/"
    tags                  = {}
    tags_all              = {}
    unique_id             = "AROA43N32K6VYZLXGDUQA"

    inline_policy {}
}
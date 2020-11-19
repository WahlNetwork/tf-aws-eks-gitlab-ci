# Provides EKS focused policy documents for GitLab EKS management
# Reference: https://gitlab.com/help/user/project/clusters/add_eks_clusters.md#new-eks-cluster
data "aws_iam_policy_document" "gitlab" {
  statement {
    sid = "GitLabEKSPolicy"
    actions = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:CreateLaunchConfiguration",
      "autoscaling:DescribeLaunchConfigurations",
      "cloudformation:CreateStack",
      "cloudformation:DescribeStacks",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:createTags",
      "ec2:DescribeImages",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "eks:CreateCluster",
      "eks:DescribeCluster",
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:CreateInstanceProfile",
      "iam:CreateServiceLinkedRole",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:ListAttachedRolePolicies", # Added per https://gitlab.com/gitlab-org/gitlab/-/issues/232960
      "iam:PassRole",
      "ssm:GetParameters"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Provides IAM policy based on the EKS policy document
resource "aws_iam_policy" "gitlab" {
  name        = "gitlab-eks-policy"
  description = "IAM Policy for GitLab EKS"
  policy      = data.aws_iam_policy_document.gitlab.json
}

# Provides a cross-account role for GitLab to authenticate and manage the EKS cluster
resource "aws_iam_role" "gitlab" {
  name               = "gitlab-eks-role"
  description        = "Provides a cross-account role for GitLab to authenticate and manage the EKS cluster"
  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.gitlab_account_id}:root"
                ]
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "${var.gitlab_external_id}"
                }
            }
        }
    ]
}
POLICY
  tags = {
    environment = var.aws_tag_environment
    source      = "Terraform"
  }
}

# Provides an attachment of the GitLabEKSPolicy policy to the new GitLab role
resource "aws_iam_role_policy_attachment" "gitlab" {
  policy_arn = aws_iam_policy.gitlab.arn
  role       = aws_iam_role.gitlab.name
}

# Provides the VPC ID value
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc_name}"]
  }
}

# Provides an AWS security group for the GitLab EKS Cluster
resource "aws_security_group" "gitlab" {
  name        = "gitlab-eks-sg"
  description = "GitLab EKS Cluster"
  vpc_id      = data.aws_vpc.vpc.id
  tags = {
    Name        = "gitlab-eks-sg"
    environment = var.aws_tag_environment
    source      = "Terraform"
  }
}

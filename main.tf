# Provides permission to make calls to other AWS services and manage the resources used with the service
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "eksClusterRole" {
  name               = "eksClusterRole"
  description        = "Provides permission to make calls to other AWS services and manage the resources used with the service"
  assume_role_policy = <<POLICY
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
POLICY
  tags = {
    environment = var.aws_tag_environment
    source      = "Terraform"
  }
}

# Provides an attachment of the default AmazonEKSClusterPolicy policy to the new eksClusterRole role
resource "aws_iam_role_policy_attachment" "eksClusterRole" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

variable aws_region {
  type        = string
  description = "The target AWS region for deploying resources"
}

variable aws_tag_environment {
  type        = string
  description = "The environment tag assigned to AWS resources"
}

variable aws_vpc_name {
  type        = string
  description = "The target AWS VPC for deploying resources"
}

variable gitlab_account_id {
  type        = string
  description = "GitLab's AWS account used to grant cross-account role access"
}

variable gitlab_external_id {
  type        = string
  description = "External ID provided by GitLab as part of the IAM role trust policy to designate who can assume the role"
}

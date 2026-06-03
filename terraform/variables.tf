variable "name" {
  description = "GitHub org/user that owns the repo (e.g. \"my-org\")."
  type        = string
}

variable "environment" {
  description = "GitHub org/user that owns the repo (e.g. \"my-org\")."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository for the demo image."
  type        = string
  default     = "demo-cicd"
}

variable "github_org" {
  description = "GitHub org/user that owns the repo (e.g. \"my-org\")."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g. \"demo-cicd\")."
  type        = string
  default     = "demo-cicd"
}

variable "github_subjects" {
  description = <<-EOT
    Subject claims allowed to assume the CI role, relative to the repo.
    Examples: "ref:refs/heads/main", "pull_request", "environment:prod".
  EOT
  type        = list(string)
  default     = ["ref:refs/heads/main", "pull_request"]
}

variable "create_oidc_provider" {
  description = <<-EOT
    Whether to create the GitHub OIDC provider. Set to false if your account
    already has a token.actions.githubusercontent.com provider.
  EOT
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    Project   = "demo-cicd"
    ManagedBy = "terraform"
  }
}

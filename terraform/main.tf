data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  # The OIDC role module prefixes each entry with "repo:", so we pass
  # "<org>/<repo>:<subject>" here.
  oidc_subjects = [
    for s in var.github_subjects : "${var.github_org}/${var.github_repo}:${s}"
  ]
  name = format("%s-%s", var.name, var.environment)

  tags = merge({}, var.tags)
}

# ---------------------------------------------------------------------------
# ECR repository — public registry module.
# ---------------------------------------------------------------------------
module "mca_data_pipeline_ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.4.0"

  repository_name                 = format("%s-cicd", local.name)
  repository_image_tag_mutability = "MUTABLE"

  repository_read_write_access_arns = [module.iam_github_oidc_role.arn]
  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = format("Keep last %s images", 10),
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = merge(local.tags, { Name = format("%s-demo-cicd", local.name) })
}

data "aws_iam_policy_document" "iam_github_oidc" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_github_oidc" {
  name   = format("%s-github-oidc-get-auth-token", local.name)
  policy = data.aws_iam_policy_document.iam_github_oidc.json
}

module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "5.55.0"

  tags = local.tags
}

module "iam_github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "5.55.0"

  name = format("%s-gha-oidc", local.name)

  subjects = var.github_subjects

  policies = {
    GetAuthToken = aws_iam_policy.iam_github_oidc.arn
  }

  tags = merge(local.tags, { Name = format("%s-gha-oidc", local.name) })
}

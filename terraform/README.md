# terraform

Provisions the AWS infrastructure for the demo CI/CD pipeline using public
registry modules:

- **ECR repository** (`terraform-aws-modules/ecr/aws`) — holds the multi-arch image.
- **GitHub OIDC provider + role** (`terraform-aws-modules/iam/aws`) — lets GitHub
  Actions assume an IAM role via OIDC (no static AWS keys). GitHub signs its OIDC
  tokens with RSA; AWS validates them against the federated provider.

## Layout

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform + provider version constraints. |
| `providers.tf` | AWS provider, region, default tags. |
| `backend.tf` | S3 remote-state backend (commented template). |
| `variables.tf` | Input variables. |
| `main.tf` | ECR + OIDC provider/role + least-privilege ECR push policy. |
| `outputs.tf` | ECR URL, CI role ARN, OIDC provider ARN. |
| `terraform.tfvars.example` | Copy to `terraform.tfvars` and fill in. |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit
terraform init
terraform plan
terraform apply
```

Then wire the outputs into [the CI workflow](../.github/workflows/ci.yml):

- `ci_role_arn`        → `role-to-assume`
- `ecr_repository_url` → `IMAGE_REPO`

## Notes

- State is local by default; configure `backend.tf` (S3 + DynamoDB lock) before
  using this for anything real.
- The CI role is scoped to this repo and the subjects in `github_subjects`
  (default: `main` branch + pull requests).
- The ECR push policy is least-privilege — it only targets the demo repo.

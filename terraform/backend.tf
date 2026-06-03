# State backend.
#
# Using local state for now (state file lives in this directory).
# This is fine for a demo / single operator.
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# When ready for shared/remote state, switch to S3 + DynamoDB locking:
#
# terraform {
#   backend "s3" {
#     bucket         = "<YOUR_TF_STATE_BUCKET>"
#     key            = "demo-cicd/terraform.tfstate"
#     region         = "ap-southeast-7"
#     dynamodb_table = "<YOUR_TF_LOCK_TABLE>"
#     encrypt        = true
#   }
# }

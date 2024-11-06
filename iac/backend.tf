# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "craa-github-action-terraform-remote-state"
    key            = "rentzone-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    # assume_role_arn = "arn:aws:iam::131975964823:role/GitHubActionsRole"  # Replace with your GitHub OIDC role ARN
  }
}


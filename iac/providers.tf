# # configure aws provider to establish a secure connection between terraform and aws
# provider "aws" {
#   region = var.region

#   default_tags {
#     tags = {
#       "Automation"  = "terraform"
#       "Project"     = var.project_name
#       "Environment" = var.environment
#     }
#   }
# }

provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::131975964823:role/terraform-assume-role"
    session_name = "CodeBuildSession"
  }

  default_tags {
    tags = {
      "Automation"  = "terraform"
      "Project"     = var.project_name
      "Environment" = var.environment
    }
  }
}

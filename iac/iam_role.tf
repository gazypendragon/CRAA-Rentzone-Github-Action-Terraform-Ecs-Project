# iam_role.tf

resource "aws_iam_role" "github_oidc_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::131975964823:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub": "repo:gazypendragon/CRAA-Rentzone-Github-Action-Terraform-Ecs-Project:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Attach Administrator Access or a specific policy if needed
resource "aws_iam_role_policy_attachment" "github_oidc_role_policy" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"  # Adjust as needed
}

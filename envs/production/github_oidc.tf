resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:vflopes/saas-*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "github_oidc" {
  path               = "/service/"
  name               = "github-oidc"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
}

# Technical debt: currently using wildcard resources until we can
# determine the exact ARNs needed for the GitHub Actions workflows (least privilege).
data "aws_iam_policy_document" "github_oidc_ci" {
  statement {
    sid    = "GitHubActionsCI"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketVersioning",
      "lambda:GetFunctionConfiguration",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:PublishVersion",
      "cloudfront:CreateInvalidation",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "FrontendS3Bucket"
    effect = "Allow"
    actions = [
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::saas-frontend-*/*",
    ]
  }
}

resource "aws_iam_policy" "github_oidc_ci" {
  path        = "/service/"
  name        = "github-actions"
  description = "IAM policy for GitHub Actions deployments"
  policy      = data.aws_iam_policy_document.github_oidc_ci.json
}

resource "aws_iam_role_policy_attachment" "github_oidc_ci_attach" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_oidc_ci.arn
}

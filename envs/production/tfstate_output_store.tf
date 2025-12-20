# IAM role for Lambda execution
data "aws_iam_policy_document" "tfstate_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "tfstate_output_store" {
  path               = "/service/"
  name               = "tfstate-output-store"
  assume_role_policy = data.aws_iam_policy_document.tfstate_assume_role.json
}

resource "aws_iam_role_policy_attachment" "tfstate_lambda_logging" {
  role       = aws_iam_role.tfstate_output_store.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "tfstate_output_store" {
  path        = "/service/"
  name        = "tfstate-output-store"
  description = "IAM policy for tfstate output store Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSMParameterStoreAccess"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
        ]
        Resource = ["arn:aws:ssm:*:*:parameter/*"]
      },
      {
        Sid    = "AllowReadTfstateFilesFromS3",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ],
        Resource = [
          data.aws_s3_bucket.tfstate.arn,
          "${data.aws_s3_bucket.tfstate.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "tfstate_output_store" {
  role       = aws_iam_role.tfstate_output_store.name
  policy_arn = aws_iam_policy.tfstate_output_store.arn
}

resource "aws_lambda_function" "tfstate_output_store" {
  filename      = "${path.module}/dummy_lambda.zip"
  function_name = "tfstate-output-store"
  role          = aws_iam_role.tfstate_output_store.arn
  memory_size   = 128
  timeout       = 10

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  lifecycle {
    ignore_changes = [
      runtime,
      handler,
    ]
  }

}

resource "aws_lambda_permission" "tfstate_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tfstate_output_store.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.tfstate.arn
}

resource "aws_s3_bucket_notification" "tfstate_notification" {
  bucket = data.aws_s3_bucket.tfstate.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.tfstate_output_store.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".tfstate"
  }

  depends_on = [aws_lambda_permission.tfstate_allow_bucket]
}

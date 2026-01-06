resource "aws_sqs_queue" "analytics" {
  name = "analytics"
}

data "aws_iam_policy_document" "analytics_sqs_policy" {
  statement {
    sid    = "AllowLambdaSendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.analytics.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:lambda:${var.region}:${var.account_id}:function:*"]
    }
  }
}

resource "aws_sqs_queue_policy" "analytics" {
  queue_url = aws_sqs_queue.analytics.id
  policy    = data.aws_iam_policy_document.analytics_sqs_policy.json
}

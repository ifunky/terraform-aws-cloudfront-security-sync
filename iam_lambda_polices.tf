data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_secgroup_updater" {
  count  = var.enabled ? 1 : 0
  statement {
    effect = "Allow"

    actions   = [
        "ec2:DescribeSecurityGroups",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
        ]
    resources = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"]
  }

  statement {
    effect = "Allow"

    actions   = [
        "ec2:DescribeSecurityGroups"
        ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "assume_role_lambda" {
  count  = var.enabled ? 1 : 0
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_sec_group_update" {
  count  = var.enabled ? 1 : 0
  name        = var.iam_role_name
  description = "Role used to update security groups using Lambda"

  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda[0].json
}

resource "aws_iam_policy" "lambda_sec_group_update" {
  count       = var.enabled ? 1 : 0
  name        = "lambda_sec_group_update"
  description = "Policy that enables Lambda to update security groups"

  policy      = data.aws_iam_policy_document.lambda_secgroup_updater[0].json
}

resource "aws_iam_role_policy_attachment" "lambda_sec_group_update_attach" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.lambda_sec_group_update[0].name
  policy_arn = aws_iam_policy.lambda_sec_group_update[0].arn
}
provider "aws" {
  alias  = "us-east-1"
}

resource "aws_sns_topic_subscription" "sns_notify_ip_space_changed" {
  count = var.enabled ? 1 : 0
  provider = aws.us-east-1

  topic_arn = var.sns_ip_change_topic
  protocol  = "lambda"
  endpoint  = aws_lambda_function.update_security_groups[0].arn
}

resource "aws_lambda_permission" "sns_notify_ip_space_changed" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_security_groups[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_ip_change_topic
}

data "null_data_source" "lambda_file" {
  inputs = {
    filename = "${path.module}/functions/update_security_groups.py"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/functions/update_security_groups.zip"
  }
}

data "archive_file" "update_security_groups" {
  count = var.enabled ? 1 : 0

  type        = "zip"
  source_file = data.null_data_source.lambda_file.outputs.filename
  output_path = data.null_data_source.lambda_archive.outputs.filename
}

resource "aws_lambda_function" "update_security_groups" {
  count = var.enabled ? 1 : 0
  
  description      = "Updates security groups with names `cloudfront_g` or `cloudfront_r` with AWS CloudFront IP addresses.  This allows load balancers to only allow traffic from CloudFront." 
  filename         = data.archive_file.update_security_groups[0].output_path

  function_name    = var.function_name
  role             = aws_iam_role.lambda_sec_group_update[0].arn
  handler          = "update_security_groups.lambda_handler"
  source_code_hash = data.archive_file.update_security_groups[0].output_base64sha256
  runtime          = "python2.7"
  timeout          = 15

  lifecycle {
    ignore_changes = [
      filename,
      last_modified,
    ]
  }
}
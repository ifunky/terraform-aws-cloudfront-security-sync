# Module Specifics

Core Version Constraints:
* `>= 0.13.5`

Provider Requirements:
* **archive:** (any version)
* **aws:** (any version)
* **null:** (any version)

## Input Variables
* `additional_error_endpoint_arns` (required): Any additional arns that will respond to an error alert
* `additional_info_endpoint_arns` (required): Any additional arns that will respond to an info alert
* `attributes` (required): Additional attributes (e.g. `1`)
* `create_dashboard` (default `"true"`): Create a Cloudfront IP space changed dashboard
* `enabled` (default `true`): Set to false to prevent the module from creating any resources
* `function_name` (default `"update_security_groups_for_cloudfront"`): Name of the Lambda function
* `iam_role_name` (default `"lambda_sec_group_updater"`): Name of the IAM role that the Lambda function will run in the context of
* `region` (required): Region that security groups will be searched in.
* `sns_alarm_error_arn` (required): SNS ARN that will be used when a Lambda function error occurs
* `sns_alarm_info_arn` (required): SNS ARN that will be used when a Lambda function executes sucessfully
* `sns_ip_change_topic` (default `"arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"`)
* `tags` (required): Additional tags (e.g. `map('BusinessUnit','XYZ')`

## Output Values
* `lambda_function_arn`: Name of the Lambda function created
* `lambda_function_name`: Friendly name of the Lambda function

## Managed Resources
* `aws_cloudwatch_dashboard.main` from `aws`
* `aws_cloudwatch_log_metric_filter.cloudfront_global_count` from `aws`
* `aws_cloudwatch_log_metric_filter.cloudfront_region_count` from `aws`
* `aws_cloudwatch_metric_alarm.lambda_error` from `aws`
* `aws_cloudwatch_metric_alarm.lambda_info` from `aws`
* `aws_iam_policy.lambda_sec_group_update` from `aws`
* `aws_iam_role.lambda_sec_group_update` from `aws`
* `aws_iam_role_policy_attachment.lambda_sec_group_update_attach` from `aws`
* `aws_lambda_function.update_security_groups` from `aws`
* `aws_lambda_permission.sns_notify_ip_space_changed` from `aws`
* `aws_sns_topic_subscription.sns_notify_ip_space_changed` from `aws`

## Data Resources
* `data.archive_file.update_security_groups` from `archive`
* `data.aws_caller_identity.current` from `aws`
* `data.aws_iam_policy_document.assume_role_lambda` from `aws`
* `data.aws_iam_policy_document.lambda_secgroup_updater` from `aws`
* `data.null_data_source.lambda_archive` from `null`
* `data.null_data_source.lambda_file` from `null`

## Problems

## Error: Unsuitable value type

(at `versions.tf` line 5)

Unsuitable value: string required


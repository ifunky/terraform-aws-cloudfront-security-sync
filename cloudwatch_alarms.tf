locals {
    sns_error_topic_arn = var.sns_alarm_error_arn
    sns_info_topic_arn  = var.sns_alarm_error_arn
    error_endpoints     = distinct(compact(concat(tolist(local.sns_error_topic_arn), var.additional_error_endpoint_arns)))
    info_endpoints      = distinct(compact(concat(tolist(local.sns_info_topic_arn), var.additional_info_endpoint_arns)))

    metric_namespace    = "CloudFrontIpSync"
    twenty_four_hours   = "86400"  # In seconds
}

resource "aws_cloudwatch_log_metric_filter" "cloudfront_global_count" {
  name           = "CloudFrontGlobalIpSyncHttpsCount"
  pattern        = "Found 1 CloudFront_g HttpsSecurityGroups to update"
  log_group_name = "/aws/lambda/${var.function_name}"

  metric_transformation {
    name      = "CloudFrontGlobalIpSyncHttpsCount"
    namespace = local.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "cloudfront_region_count" {
  name           = "CloudFrontRegionIpSyncHttpsCount"
  pattern        = "Found 1 CloudFront_r HttpsSecurityGroups to update"
  log_group_name = "/aws/lambda/${var.function_name}"

  metric_transformation {
    name      = "CloudFrontRegionIpSyncHttpsCount"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.default
  ]  
}

resource "aws_cloudwatch_metric_alarm" "lambda_error" {
    alarm_name                = "error::${var.function_name}"
    comparison_operator       = "GreaterThanOrEqualToThreshold" 
    evaluation_periods        = "1" 
    metric_name               = "Errors" 
    namespace                 = "AWS/Lambda" 
    period                    = "300"   # 5mins
    statistic                 = "SampleCount" 
    threshold                 = "1"
    alarm_description         = "Monitors Lambda errors"
    alarm_actions             = local.error_endpoints
    dimensions = {
      FunctionName = "update_security_groups_for_cloudfront"
      Resource = "update_security_groups_for_cloudfront"
    }
}

resource "aws_cloudwatch_metric_alarm" "lambda_info" {
    alarm_name                = "info::global_ip_update::${var.function_name}"
    comparison_operator       = "GreaterThanOrEqualToThreshold" 
    evaluation_periods        = "1" 
    metric_name               = "CloudFrontGlobalIpSyncHttpsCount" 
    namespace                 = local.metric_namespace 
    period                    = "86400"   # 24hours
    statistic                 = "Sum" 
    threshold                 = "1"
    alarm_description         = "Info alert when sec groups updated automatically for global CloudFront IPs"
    alarm_actions             = local.info_endpoints
    #depends_on = [aws_cloudwatch_log_metric_filter.cloudfront_global_count]
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "additional_error_endpoint_arns" {
  type        = list
  description = "Any additional arns that will respond to an error alert"
  default     = []
}

variable "additional_info_endpoint_arns" {
  type        = list
  description = "Any additional arns that will respond to an info alert"
  default     = []
}

variable "create_dashboard" {
  description = "Create a Cloudfront IP space changed dashboard"
  default     = "true"
}

variable "function_name" {
  description = "Name of the Lambda function"
  default     = "update_security_groups_for_cloudfront"
}

variable "sns_alarm_error_arn" {
  description = "SNS ARN that will be used when a Lambda function error occurs"
  default     = ""  
}

variable "sns_alarm_info_arn" {
  description = "SNS ARN that will be used when a Lambda function executes sucessfully"
  default     = ""  
}

variable "sns_ip_change_topic" {
    description = ""
    default     = "arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged"
}

variable "region" {
    description = "Region that security groups will be searched in."
}

variable "iam_role_name" {
  description = "Name of the IAM role that the Lambda function will run in the context of"
  default     = "lambda_sec_group_updater"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}
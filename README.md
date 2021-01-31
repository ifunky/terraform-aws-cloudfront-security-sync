<!-- Auto generated file -->

# AWS CloudFront Security Group Syncronisation


 [![Build Status](https://circleci.com/gh/ifunky/terraform-aws-cloudfront-security-sync.svg?style=svg)](https://circleci.com/gh/ifunky/terraform-aws-cloudfront-security-sync) [![Latest Version](https://img.shields.io/github/release/ifunky/terraform-aws-cloudfront-security-sync.svg)](https://github.com/ifunky/terraform-aws-cloudfront-security-sync/releases)

When using AWS WAF to secure your web applications, it’s important to ensure that only CloudFront can access your origin; otherwise, someone could bypass
AWS WAF itself. If your origin is an Elastic Load Balancing load balancer or an Amazon EC2 instance, you can use VPC security groups to allow only
CloudFront to access your applications. You can accomplish this by creating a security group that only allows the specific IP 
ranges of CloudFront. AWS publishes these IP ranges in JSON format so that you can create networking configurations that use them. These ranges are 
separated by service and region, which means you’ll only need to allow IP ranges that correspond to CloudFront.

This module creates the resources necessary that update a security group's ingress rules to restrict traffic from the CloudFront IP addresses.

__NOTE:__ For additional security you may like to also implement an `Origin Custom Header` and add a WAF WebACL rule that restricts traffic to this header.  The 
reason for doing this would be to avoid an external attempt at pointing a different CDN to your publically available orgin (if using an ALB).

## Features

### SNS subscription

- A subscription to `arn:aws:sns:us-east-1:806199016981:AmazonIpSpaceChanged` wil be added to the `us-east-1` region.  The subscription must be in this region as that's where Amazon's topic exists 

### Lambda Configuration
- A Lambda function that is triggered from the SNS subscription
- IAM role for the function

### Monitoring and alerting
- Lambda error notification to SNS
- Success notification to SNS
- Cloudwatch dashboard showing IP space changes over time

# Setting up your project
Due to the SNS subscription being created in the us-east-1 region (as that's where the topic is) the calling code needs some extra config.

## AWS Provider
Setup an alias AWS provider like the following which will be passwed into the calling module:

```hcl
  provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  assume_role {
    role_arn          = var.terraform_role_arn
    session_name      = "terraform"
  }    
}
```
## Security Groups
In order for the Lambda function to find the correct security groups to dynamically update you must create two security groups with some specific tags as shown below:-

```hcl
  resource "aws_security_group" "alb_global" {
    name        = "sg_alb_cloudfront_global"
    description = "ALB security rules for global CloudFront IP addresses"
    vpc_id      = module.vpc.vpc_id

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }  

    tags = {
      Name        = "sg_alb_cloudfront_global"
      Type        = "cloudfront_g"
      AutoUpdate  = "true"
      Protocol    = "https"
    }

    lifecycle { 
      ignore_changes = [ingress] 
    }      
  }

  resource "aws_security_group" "alb_regional" {
    name        = "sg_alb_cloudfront_regional"
    description = "ALB security rules for regional CloudFront IP addresses"
    vpc_id      = module.vpc.vpc_id

    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }  

    tags = {
      Name        = "sg_alb_cloudfront_regional"
      Type        = "cloudfront_r"
      AutoUpdate  = "true"
      Protocol    = "https"
    }

    lifecycle { 
      ignore_changes = ["ingress"] 
    }      
  }    
```



## Usage
```hcl
module "cloudfront_lambda_updater" {
  source = "git::https://github.com/ifunky/terraform-aws-cloudfront-security-sync.git?ref=master"

  region              = "eu-west-1"
  iam_role_name       = "lambda_sec_group_updater"
  sns_alarm_error_arn = "arn:aws:sns:eu-west-1:123456789012:audit-alerts-dev"
  sns_alarm_info_arn  = "arn:aws:sns:eu-west-1:123456789012:audit-info-dev"

  providers = {
      aws.us-east-1 = aws.us-east-1
  }

  tags = {
    Terraform = "true"
  }
}
```


## Makefile Targets
The following targets are available: 

```
createdocs/help                Create documentation help
polydev/createdocs             Run PolyDev createdocs directly from your shell
polydev/help                   Help on using PolyDev locally
polydev/init                   Initialise the project
polydev/validate               Validate the code
polydev                        Run PolyDev interactive shell to start developing with all the tools or run AWS CLI commands :-)
```
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


## Related Projects

Here are some useful related projects.

- [PolyDev](https://github.com/ifunky/polydev) - PolyDev repo and setup guide





## References

For more information please see the following links of interest: 

- [AWS CloudFront, WAF and Security Groups](https://aws.amazon.com/blogs/security/how-to-automatically-update-your-security-groups-for-amazon-cloudfront-and-aws-waf-by-using-aws-lambda/) - Amazon blog post with manual instructions
- [AWS Code Examples](https://github.com/aws-samples/aws-cloudfront-samples) - Github code examples
- [AWS IP Ranges](https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html) - AWS offical IP ranges documentation
- [AWS Metric Filters Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) - AWS offical documentaion for Cloudwatch filters


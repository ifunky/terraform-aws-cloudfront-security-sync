output "lambda_function_arn" {
  description = "Name of the Lambda function created"
  value       = var.enabled ? join("", aws_lambda_function.update_security_groups.*.arn) : ""  
}

output "lambda_function_name" {
  description = "Friendly name of the Lambda function"
  value       = var.function_name  
}


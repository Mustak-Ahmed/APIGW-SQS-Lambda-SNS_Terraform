variable "environment" {
    description = "Env"
    default     = "dev"
}

variable "name" {
    description = "Application Name"
    type        = string
}

locals {
    description = "Aplication Name"
    app_name = "${var.name}-${var.environment}"
}

variable "region" {
    default = "us-east-1"
}

variable "lambda_name" {
    description = "Name for lambda function"
    default = "lambda"
}
variable "app_prefix" {
  
}
variable "lambda_runtime" {
  default = "python3.7"
}
variable "lambda_handler" {
  default = "handler.lambda_handler"
}
variable "lambda_timeout" {
    default = 30
  
}
variable "lambda_memory" {
    default = 128
  
}
variable "lambda_statement_id" {
  default = "AllowExecutionFromSQS"
}
variable "lambda-action" {
  default = "lambda:InvokeFunction"
}
variable "lambda_sqs_principal" {
    default = "sqs.amazonaws.com"
  
}
variable "lambda_policy_desc" {
  default = "AWS IAM Policy for managing aws lambda role"
}
  variable "delay_seconds" {
    default = 0
  }
  variable "max_message_size" {
    default = 262144
  }
  variable "message_retention_seconds" {
    default=86400
  }
variable "receive_wait_time_seconds" {
  default = 10
}
variable "sns_protocol" {
  default = "email"
}
variable "sns_endpoint" {
  default = "mustakahmed411@gmail.com"
}
variable "apigw_description" {
  default = "POST records to SQS queue"
}
variable "apigw_path_part" {
  default = "form-score"
}
variable "apigw_method" {
  default="POST"
}
variable "apigw_authorization" {
  default="NONE"
}
variable "model_descr" {
  default = "a JSON schema"
}
variable "model_content_type" {
  default = "application/json"
}
variable "apigw_key_type" {
  default="API_KEY"
}
variable "integration_type" {
  default="AWS"
}
variable "selection_pattern" {
  default = "^2[0-9][0-9]"
}
variable "lambda_policy_desc_sqs" {
  default = "IAM policy for lambda Being invoked by SQS"
}
variable "apigw_model_name" {
  default= "validatebody"
}
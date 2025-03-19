variable "region" {
    default = "us-west-1"
}

variable "env" {
    default = "dev"
}

variable "function_name" {
    default = "DEV_hello_world"
}

variable "handler" {
    default = "handler"
}

variable "lambda_functions" {
    default = "lambda_functions.zip"
}

variable "iam_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}
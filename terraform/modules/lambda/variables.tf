variable "region" {
    default = "us-west-1"
}

variable "environment" {
    default = "dev"
}

variable "function_name" {
    default = "DEV_hello_world"
}

variable "handler" {
    default = "handler"
}

variable "iam_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}
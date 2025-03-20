variable "region" {
    default = "us-west-1"
}

variable "environment" {
    default = "dev"
}

variable "iam_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}
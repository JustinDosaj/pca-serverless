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

variable "openai_api_key" {
  description = "The OpenAI API Key"
  type        = string
  sensitive   = true
}
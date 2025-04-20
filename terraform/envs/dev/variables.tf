variable "region" {
  default = "us-west-1"
}

variable "aws-profile" {
  default = "my-profile" # Change to your AWS config profile
}

variable "environment" {
  default = "dev"
}

variable "openai_api_key" {
  description = "The OpenAI API Key"
  type        = string
  sensitive   = true
}

variable "iam_account_id" {
  description = "AWS Account ID"
  type = string
  sensitive = true
}

variable "cognito_id" {
  description = "Cognito ID"
  type = string
  sensitive = true
}

variable "cognito_client_id" {
  description = "Cognito Client ID"
  type = string
  sensitive = true
}
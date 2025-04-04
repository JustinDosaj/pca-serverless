variable "region" {
    default = "us-west-1"
}

variable "environment" {
    default = "dev"
}

variable "chat_completion_invoke_arn" {
  description = "Invoke ARN for chat_completion function"
  type        = string
}

variable "chat_completion_arn" {
    description = "ARN for lambda function"
}

variable "cognito_user_pool_client_id" {
    description = "Cognito user pool client id"
    type = string
}

variable "cognito_user_pool_id" {
    description = "Cognito user pool id"
    type = string
}

variable "chat_completion_function_url" {
    description = "Chat Completion function URL"
    type = string
}
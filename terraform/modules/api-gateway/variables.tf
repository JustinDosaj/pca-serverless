variable "region" {
    type = string
    default = "us-west-1"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "chat_completion_invoke_arn" {
    type        = string
    description = "Invoke ARN for chat_completion function"
}

variable "chat_completion_arn" {
    type = string
    description = "ARN for lambda function"
}

variable "cognito_user_pool_client_id" {
    type = string
    description = "Cognito user pool client id"
}

variable "cognito_user_pool_id" {
    type = string
    description = "Cognito user pool id"
}

variable "chat_completion_function_url" {
    type = string
    description = "Chat Completion function URL"
}
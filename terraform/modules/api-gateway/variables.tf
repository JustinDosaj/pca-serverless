variable "region" {
    type = string
    default = "us-west-1"
}

variable "environment" {
    type = string
    default = "dev"
}

# Chat Completion
variable "chat_completion_invoke_arn" {
    type        = string
    description = "Invoke ARN for chat_completion function"
}

variable "chat_completion_arn" {
    type = string
    description = "ARN for lambda function"
}

variable "chat_completion_function_url" {
    type = string
    description = "Chat Completion function URL"
}

# Get Conversation
variable "get_conversations_invoke_arn" {
    type = string
    description = "Get Conversations Invoke ARN"
}

variable "get_conversations_arn" {
    type = string
    description = "Get Converastions ARN"
}

# Cognito
variable "cognito_user_pool_client_id" {
    type = string
    description = "Cognito user pool client id"
}

variable "cognito_user_pool_id" {
    type = string
    description = "Cognito user pool id"
}
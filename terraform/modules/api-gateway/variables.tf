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

# Get Conversation
variable "get_conversations_invoke_arn" {
    type = string
    description = "Get Conversations Invoke ARN"
}

# Delete Conversation
variable "delete_conversation_invoke_arn" {
    type = string
    description = "Delete Conversation Invoke ARN"
}

# Get Messages
variable "get_messages_invoke_arn" {
    type = string
    description = "Get Conversations Invoke ARN"
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
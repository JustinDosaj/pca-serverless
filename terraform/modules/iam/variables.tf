variable "environment" {
    type = string
    default = "dev"
}

variable "region" {
    type = string
    default = "us-west-1"
}

variable "api_id" {
    type = string
    description = "API ID"
}

variable "account_id" {
    type = string
    description = "Account ID"
}

variable "users_table_arn" {
    type = string
    description = "ARN for users table in DynamoDB"
}

variable "conversations_table_arn" {
    type = string
    description = "ARN for conversations table in DynamoDB"
}

variable "messages_table_arn" {
    type = string
    description = "ARN for messages table in DynamoDB"
}
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


variable "chat_table_arn" {
    type = string
    description = "ARN for chat history table in DynamoDB"
}
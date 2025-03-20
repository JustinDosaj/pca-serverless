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
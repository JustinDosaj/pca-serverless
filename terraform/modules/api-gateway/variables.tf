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

variable cognito_user_pool_client_id {
    default = "30oarcfi7d6rseca2234957fm6"
}

variable cognito_user_pool_id {
    default = "us-west-1_9ZbuQizvZ"
}
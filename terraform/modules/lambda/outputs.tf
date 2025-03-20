output "chat_completion_invoke_arn" {
    value = aws_lambda_function.chat_completion.invoke_arn
}

output "chat_completion_arn" {
    value = aws_lambda_function.chat_completion.arn
}
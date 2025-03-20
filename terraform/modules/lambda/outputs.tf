output "chat_completion_uri" {
    value = aws_lambda_function.chat_completion.invoke_arn
}

output "chat_completion_arn" {
    value = aws_lambda_function.chat_completion.arn
}
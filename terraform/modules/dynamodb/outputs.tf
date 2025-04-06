output "users_table_arn" {
    value = aws_dynamodb_table.users_table.arn
}

output "conversations_table_arn" {
    value = aws_dynamodb_table.conversations_table.arn
}

output "messages_table_arn" {
    value = aws_dynamodb_table.messages_table.arn
}
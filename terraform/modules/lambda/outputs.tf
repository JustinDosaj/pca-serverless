# Chat Completion
output "chat_completion_invoke_arn" {
    value = aws_lambda_function.chat_completion.invoke_arn
}

# Get Conversations
output "get_conversations_invoke_arn" {
    value = aws_lambda_function.get_conversations.invoke_arn
}

# Delete Conversation
output "delete_conversation_invoke_arn" {
    value = aws_lambda_function.delete_conversation.invoke_arn
}

# Get Messages
output "get_messages_invoke_arn" {
    value = aws_lambda_function.get_messages.invoke_arn
}
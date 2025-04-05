resource "aws_dynamodb_table" "chat-history-table" {
    name = "${var.environment}_ChatHistory"
    
}
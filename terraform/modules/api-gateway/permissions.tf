# Lambda permissions for APIs
resource "aws_lambda_permission" "chat_completion_permission" {
  statement_id  = "AllowChatAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.environment}_chat_completion"
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn for HTTP API
  source_arn = "${aws_apigatewayv2_api.private_chat_api.execution_arn}/*/*/chat"
}

resource "aws_lambda_permission" "get_conversations_permission" {
  statement_id  = "AllowChatAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.environment}_get_conversations"
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn for HTTP API
  source_arn = "${aws_apigatewayv2_api.private_chat_api.execution_arn}/*/*/conversations"
}

resource "aws_lambda_permission" "delete_conversation_permission" {
  statement_id  = "AllowChatAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.environment}_delete_conversation"
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn for HTTP API
  source_arn = "${aws_apigatewayv2_api.private_chat_api.execution_arn}/*/*/conversations/*"
}

resource "aws_lambda_permission" "edit_conversation_permission" {
  statement_id  = "AllowChatAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.environment}_edit_conversation"
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn for HTTP API
  source_arn = "${aws_apigatewayv2_api.private_chat_api.execution_arn}/*/*/conversations/*"
}

resource "aws_lambda_permission" "get_messages_permission" {
  statement_id  = "AllowChatAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.environment}_get_messages"
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn for HTTP API
  source_arn = "${aws_apigatewayv2_api.private_chat_api.execution_arn}/*/*/messages"
}
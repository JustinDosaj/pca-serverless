# HTTP API instead of REST API
resource "aws_apigatewayv2_api" "private_chat_api" {
  name          = "${var.environment}_private_chat_api"
  protocol_type = "HTTP"
  description   = "API for chat completion with streaming support"
  cors_configuration {
    allow_credentials = true
    allow_headers     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    allow_methods     = ["POST", "GET", "OPTIONS", "DELETE", "PUT"]
    allow_origins     = ["http://localhost:3000"] # Add your frontend origins here
    max_age           = 240 # 3 minutes
  }
}

# JWT Authorizer connected to your Amplify-created Cognito User Pool
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name             = "cognito-authorizer"
  api_id           = aws_apigatewayv2_api.private_chat_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# Integration between the API and your Lambda function
resource "aws_apigatewayv2_integration" "chat_integration" {
  api_id             = aws_apigatewayv2_api.private_chat_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.chat_completion_invoke_arn
  payload_format_version = "2.0"
}

# Route for your chat endpoint with authorization
resource "aws_apigatewayv2_route" "chat_route" {
  api_id    = aws_apigatewayv2_api.private_chat_api.id
  route_key = "POST /chat"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.chat_integration.id}"
}

# API integrations and Routes for Conversations
resource "aws_apigatewayv2_integration" "get_conversations_integration" {
  api_id             = aws_apigatewayv2_api.private_chat_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.get_conversations_invoke_arn
  payload_format_version = "2.0" 
}

resource "aws_apigatewayv2_route" "get_conversations_route" {
  api_id    = aws_apigatewayv2_api.private_chat_api.id
  route_key = "GET /conversations"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.get_conversations_integration.id}"
}

resource "aws_apigatewayv2_integration" "delete_conversation_integration" {
  api_id             = aws_apigatewayv2_api.private_chat_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.delete_conversation_invoke_arn
  payload_format_version = "2.0" 
}

resource "aws_apigatewayv2_route" "delete_conversation_route" {
  api_id    = aws_apigatewayv2_api.private_chat_api.id
  route_key = "DELETE /conversations/{conversationId}"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.delete_conversation_integration.id}"
}

resource "aws_apigatewayv2_integration" "edit_conversation_integration" {
  api_id             = aws_apigatewayv2_api.private_chat_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.edit_conversation_invoke_arn# Swap this function
  payload_format_version = "2.0" 
}

resource "aws_apigatewayv2_route" "edit_conversation_route" {
  api_id    = aws_apigatewayv2_api.private_chat_api.id
  route_key = "PUT /conversations/{conversationId}"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.edit_conversation_integration.id}"
}

# Inegration between API and get messages function
resource "aws_apigatewayv2_integration" "get_messages_integration" {
  api_id             = aws_apigatewayv2_api.private_chat_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.get_messages_invoke_arn
  payload_format_version = "2.0" 
}

resource "aws_apigatewayv2_route" "get_messages_route" {
  api_id    = aws_apigatewayv2_api.private_chat_api.id
  route_key = "GET /messages"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.get_messages_integration.id}"
}

# Stage for the API - With auto deploy enabled
resource "aws_apigatewayv2_stage" "chat_stage" {
    api_id = aws_apigatewayv2_api.private_chat_api.id
    name   = var.environment
    auto_deploy = true
    default_route_settings {
        throttling_burst_limit = 100
        throttling_rate_limit = 50
    }
}

# Lambda permissions
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
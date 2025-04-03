# WEBSOCKET API

resource "aws_apigatewayv2_api" "chat_completion_api" {
  name          = "${var.environment}_chat_completion_api"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  description   = "API for chat completion with streaming support"
}

# JWT Authorizer connected to your Amplify-created Cognito User Pool
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = "${aws_apigatewayv2_api.chat_completion_api.id}"
  authorizer_type  = "REQUEST"
  authorizer_uri   = var.chat_completion_invoke_arn
  identity_sources = ["route.request.header.Auth"]
  name             = "cognito-authorizer"
}

# Route for your chat endpoint with authorization - CORRECTED
resource "aws_apigatewayv2_route" "chat_route" {
  api_id    = aws_apigatewayv2_api.chat_completion_api.id
  route_key = "sendMessage"
  
  authorization_type = "NONE"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.chat_integration.id}"
}

# Integration between the API and your Lambda function
resource "aws_apigatewayv2_integration" "chat_integration" {
  api_id             = aws_apigatewayv2_api.chat_completion_api.id
  integration_uri    = var.chat_completion_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Stage for the API - With auto deploy enabled
resource "aws_apigatewayv2_stage" "chat_stage" {
  api_id = aws_apigatewayv2_api.chat_completion_api.id
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
  source_arn = "${aws_apigatewayv2_api.chat_completion_api.execution_arn}/*/*/chat-completion"
}
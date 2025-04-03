# HTTP API instead of REST API
resource "aws_apigatewayv2_api" "chat_completion_api" {
  name          = "${var.environment}_chat_completion_api"
  protocol_type = "HTTP"
  description   = "API for chat completion with streaming support"
  cors_configuration {
    allow_credentials = true
    allow_headers     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    allow_methods     = ["POST", "OPTIONS"]
    allow_origins     = ["http://localhost:3000"] # Add your frontend origins here
    max_age           = 240 # 3 minutes
  }
}

# JWT Authorizer connected to your Amplify-created Cognito User Pool
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name             = "cognito-authorizer"
  api_id           = aws_apigatewayv2_api.chat_completion_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

# Integration between the API and your Lambda function
resource "aws_apigatewayv2_integration" "chat_integration" {
  api_id             = aws_apigatewayv2_api.chat_completion_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.chat_completion_invoke_arn
  payload_format_version = "2.0"  # Use the newer format for HTTP APIs
}

# Route for your chat endpoint with authorization - CORRECTED
resource "aws_apigatewayv2_route" "chat_route" {
  api_id    = aws_apigatewayv2_api.chat_completion_api.id
  route_key = "POST /chat-completion"
  
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  
  # Link directly to the integration
  target = "integrations/${aws_apigatewayv2_integration.chat_integration.id}"
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
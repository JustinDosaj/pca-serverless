# Outputs for the API endpoint
output "api_endpoint" {
  value = "${aws_apigatewayv2_stage.chat_stage.invoke_url}/chat-completion"
}

output "api_id" {
  value = aws_apigatewayv2_api.chat_completion_api.id
}
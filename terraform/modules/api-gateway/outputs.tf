# Outputs for the API endpoint
output "api_endpoint" {
  value = "${aws_apigatewayv2_stage.chat_stage.invoke_url}/chat-completion"
}
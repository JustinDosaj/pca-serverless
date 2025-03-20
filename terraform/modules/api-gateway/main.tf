resource "aws_api_gateway_rest_api" "ChatAPI" {
    name = "${var.environment}_ChatAPI"
    description = "API for chat completion"
}

resource "aws_api_gateway_resource" "ChatResource" {
    rest_api_id = "${aws_api_gateway_rest_api.ChatAPI.id}"
    parent_id   = "${aws_api_gateway_rest_api.ChatAPI.root_resource_id}"
    path_part   = "test"
}

// TODO: Add authorization
resource "aws_api_gateway_method" "ChatMethod" {
    rest_api_id   = "${aws_api_gateway_rest_api.ChatAPI.id}"
    resource_id   = "${aws_api_gateway_resource.ChatResource.id}"
    http_method   = "POST"
    authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "ChatMethodSettings" {
    rest_api_id = "${aws_api_gateway_rest_api.ChatAPI.id}"
    stage_name = "${aws_api_gateway_stage.ChatStages.stage_name}"
    method_path = "${aws_api_gateway_resource.ChatResource.path_part}/${aws_api_gateway_method.ChatMethod.http_method}"

    settings {
        metrics_enabled = true
    }
}

resource "aws_api_gateway_integration" "ChatIntegration" {
    rest_api_id = "${aws_api_gateway_rest_api.ChatAPI.id}"
    resource_id = "${aws_api_gateway_resource.ChatResource.id}"
    http_method = "${aws_api_gateway_method.ChatMethod.http_method}"
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${var.chat_completion_invoke_arn}"
}

resource "aws_api_gateway_deployment" "ChatDeployment" {

    depends_on = [aws_api_gateway_integration.ChatIntegration]
    rest_api_id = "${aws_api_gateway_rest_api.ChatAPI.id}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "ChatStages" {
  stage_name    = "${var.environment}"
  rest_api_id   = "${aws_api_gateway_rest_api.ChatAPI.id}"
  deployment_id = "${aws_api_gateway_deployment.ChatDeployment.id}"
}

resource "aws_lambda_permission" "chat_completion_permission" {
    statement_id  = "AllowChatAPIInvoke"
    action        = "lambda:InvokeFunction"
    function_name = "${var.environment}_chat_completion"
    principal     = "apigateway.amazonaws.com"

    # The /*/* part allows invocation from any stage, method and resource path
    # within API Gateway REST API.
    source_arn = "${aws_api_gateway_rest_api.ChatAPI.execution_arn}/*/*" 
}
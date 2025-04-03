resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.environment}_iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Define IAM policy for Lambda to interact with API Gateway WebSocket connections
resource "aws_iam_policy" "lambda_api_gateway_policy" {
  name        = "LambdaApiGatewayPolicy"
  description = "Policy that allows Lambda to post messages to WebSocket connections"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "execute-api:ManageConnections"
        Effect   = "Allow"
        Resource = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.api_id}/*/POST/@connections/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_logs" {
  name   = "lambda-logs-policy"
  role   = aws_iam_role.iam_for_lambda.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}


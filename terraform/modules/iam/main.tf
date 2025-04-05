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

resource "aws_iam_policy" "dynamodb_chat_access" {
  name        = "${var.environment}_DynamoDBChatAccess"
  description = "Allows Lambda to access chat history table and perform all necessary DynamoDB operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ],
        Resource = [
          "${var.chat_table_arn}",
          "${var.chat_table_arn}/index/*" # access to GSIs
        ],
        Condition = {
            "ForAllValues:StringEquals": {
            "dynamodb:LeadingKeys": [
                "USER#$$${cognito-identity.amazonaws.com:sub}"
            ]
            }
        }
      }
    ]
  })
}
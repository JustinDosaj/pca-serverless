provider "aws" {
  region      = var.region
  profile     = var.aws-profile
  # endpoints {
  #   # lambda    = "http://localstack:4566"
  # }
}

resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"

    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    }
    EOF
}

resource "aws_lambda_function" "lambda" {
    filename = "lambda_functions.zip"
    function_name = "hello_world"
    role = "${aws_iam_role.iam_for_lambda.arn}"
    handler = "handler"

    source_code_hash = "${filebase64sha256("lambda_functions.zip")}"

    runtime = "nodejs22.x"
}
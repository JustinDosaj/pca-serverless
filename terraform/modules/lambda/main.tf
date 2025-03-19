resource "aws_lambda_function" "lambda" {
    filename = "lambda_functions.zip"
    function_name = var.function_name
    role = "${var.iam_role_arn}"
    handler = var.handler
    source_code_hash = "${filebase64sha256("lambda_functions.zip")}"
    runtime = "nodejs22.x"
}
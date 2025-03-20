resource "aws_lambda_function" "chat_completion" {
    filename = "lambda_functions.zip"
    function_name = "${var.environment}_chat_completion"
    role = "${var.iam_role_arn}"
    handler = "index.handler"
    source_code_hash = "${filebase64sha256("lambda_functions.zip")}"
    runtime = "nodejs22.x"
}
data "archive_file" "chat_packages_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../layers/chat-layer"
    output_path = "${path.root}/builds/chat_packages_zip"
}

resource "aws_lambda_layer_version" "chat_layer" {
    layer_name = "chat-layer"
    description = "Layer containing chatCompletion dependencies"
    
    filename = data.archive_file.chat_packages_zip.output_path
    source_code_hash = data.archive_file.chat_packages_zip.output_base64sha256
    
    compatible_runtimes = ["nodejs22.x"]
}

data "archive_file" "chat_completion_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../functions/chat-completion"
    output_path = "${path.root}/builds/chat-completion.zip"
}

resource "aws_lambda_function" "chat_completion" {
    function_name = "${var.environment}_chat_completion"
    handler = "index.handler"
    runtime = "nodejs22.x"
    
    filename = data.archive_file.chat_completion_zip.output_path
    source_code_hash = data.archive_file.chat_completion_zip.output_base64sha256
    
    layers = [aws_lambda_layer_version.chat_layer.arn]
    
    role = "${var.iam_role_arn}"    
    timeout = 30
    memory_size = 256

    environment {
      variables = {
        OPENAI_API_KEY = "${var.openai_api_key}"
      }
    }
}

resource "aws_lambda_function_url" "chat_completion_url" {
  function_name = aws_lambda_function.chat_completion.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["http://localhost:3000"]  # Match your API Gateway CORS
    allow_methods     = ["POST"]
    allow_headers     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    max_age           = 240
  }
}
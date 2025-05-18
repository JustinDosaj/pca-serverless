# Layers
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

# Completions
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

    tags = {
        name = "${var.environment}_chat_completion"
    }
}

# Conversations
data "archive_file" "get_conversations_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../functions/get-conversations"
    output_path = "${path.root}/builds/get-conversations.zip"
}

resource "aws_lambda_function" "get_conversations" {
    function_name = "${var.environment}_get_conversations"
    handler = "index.handler"
    runtime = "nodejs22.x"

    filename = data.archive_file.get_conversations_zip.output_path
    source_code_hash = data.archive_file.get_conversations_zip.output_base64sha256
    
    role = "${var.iam_role_arn}"    
    timeout = 10
    memory_size = 256

    tags = {
        name = "${var.environment}_get_conversations"
    }
}

data "archive_file" "get_messages_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../functions/get-messages"
    output_path = "${path.root}/builds/get-messages.zip"
}

resource "aws_lambda_function" "get_messages" {
    function_name = "${var.environment}_get_messages"
    handler = "index.handler"
    runtime = "nodejs22.x"

    filename = data.archive_file.get_messages_zip.output_path
    source_code_hash = data.archive_file.get_messages_zip.output_base64sha256
    
    role = "${var.iam_role_arn}"    
    timeout = 10
    memory_size = 256

    tags = {
        name = "${var.environment}_get_messages"
    }
}

data "archive_file" "delete_conversation_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../functions/delete-conversation"
    output_path = "${path.root}/builds/delete-conversation.zip"
}

resource "aws_lambda_function" "delete_conversation" {
    function_name = "${var.environment}_delete_conversation"
    handler = "index.handler"
    runtime = "nodejs22.x"

    filename = data.archive_file.delete_conversation_zip.output_path
    source_code_hash = data.archive_file.delete_conversation_zip.output_base64sha256
    
    role = "${var.iam_role_arn}"    
    timeout = 10
    memory_size = 256

    tags = {
        name = "${var.environment}_delete_conversation"
    }
}

data "archive_file" "edit_conversation_zip" {
    type = "zip"
    source_dir = "${path.root}/../../../functions/edit-conversation"
    output_path = "${path.root}/builds/edit-conversation.zip"
}

resource "aws_lambda_function" "edit_conversation" {
    function_name = "${var.environment}_edit_conversation"
    handler = "index.handler"
    runtime = "nodejs22.x"

    filename = data.archive_file.edit_conversation_zip.output_path
    source_code_hash = data.archive_file.edit_conversation_zip.output_base64sha256
    
    role = "${var.iam_role_arn}"    
    timeout = 10
    memory_size = 256

    tags = {
        name = "${var.environment}_edit_conversation"
    }
}
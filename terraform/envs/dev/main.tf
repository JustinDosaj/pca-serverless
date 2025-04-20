provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_module" {
    source = "../../modules/iam"
    account_id = var.iam_account_id
    environment = var.environment
    api_id = module.api_gateway_module.api_id
    users_table_arn = module.dynamodb_module.users_table_arn
    conversations_table_arn = module.dynamodb_module.conversations_table_arn
    messages_table_arn = module.dynamodb_module.messages_table_arn
}

module "lambda_module" {
    source = "../../modules/lambda"
    environment = var.environment
    iam_role_arn = module.iam_module.iam_role_arn
    openai_api_key = var.openai_api_key
}

module "api_gateway_module" {
    source                        = "../../modules/api-gateway"
    environment                   = var.environment
    region                        = var.region

    # Chat Completion ARN & Function URL
    chat_completion_invoke_arn    = module.lambda_module.chat_completion_invoke_arn

    # Conversations ARNs
    get_conversations_invoke_arn = module.lambda_module.get_conversations_invoke_arn
    delete_conversation_invoke_arn = module.lambda_module.delete_conversation_invoke_arn
    edit_conversation_invoke_arn = module.lambda_module.edit_conversation_invoke_arn

    # Get Messages ARN
    get_messages_invoke_arn = module.lambda_module.get_messages_invoke_arn
    
    cognito_user_pool_id = var.cognito_id
    cognito_user_pool_client_id = var.cognito_client_id
}

module "dynamodb_module" {
    source = "../../modules/dynamodb"
}



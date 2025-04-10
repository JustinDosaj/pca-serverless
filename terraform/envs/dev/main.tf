provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_module" {
    source = "../../modules/iam"
    account_id = "211125545153"
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
    
    # Add these variables with values from your Amplify project
    cognito_user_pool_id       = "us-west-1_9ZbuQizvZ" # Replace with your actual Amplify-created User Pool ID
    cognito_user_pool_client_id = "30oarcfi7d6rseca2234957fm6" # Replace with your actual Amplify-created App Client ID
}

module "dynamodb_module" {
    source = "../../modules/dynamodb"
}



provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_module" {
    source = "../../modules/iam"
    account_id = "211125545153"
    environment = var.environment
    api_id = module.api_gateway_module.api_id
    chat_table_arn = module.dynamodb_module.chat_table_arn
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
    chat_completion_invoke_arn    = module.lambda_module.chat_completion_invoke_arn
    chat_completion_arn           = module.lambda_module.chat_completion_arn
    chat_completion_function_url  = module.lambda_module.chat_completion_function_url
    region                        = var.region
    
    # Add these variables with values from your Amplify project
    cognito_user_pool_id       = "us-west-1_9ZbuQizvZ" # Replace with your actual Amplify-created User Pool ID
    cognito_user_pool_client_id = "30oarcfi7d6rseca2234957fm6" # Replace with your actual Amplify-created App Client ID
}

module "dynamodb_module" {
    source = "../../modules/dynamodb"
}



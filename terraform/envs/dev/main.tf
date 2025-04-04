provider "aws" {
    region      = var.region
    profile     = var.aws-profile
}

module "iam_for_lambda" {
    source = "../../modules/iam"
    account_id = "211125545153"
    environment = var.environment
    api_id = module.chat_completion_api.api_id
}

module "chat_completion" {
    source = "../../modules/lambda"
    environment = var.environment
    iam_role_arn = module.iam_for_lambda.iam_role_arn
    openai_api_key = var.openai_api_key
}

module "chat_completion_api" {
    source                        = "../../modules/api-gateway"
    environment                   = var.environment
    chat_completion_invoke_arn    = module.chat_completion.chat_completion_invoke_arn
    chat_completion_arn           = module.chat_completion.chat_completion_arn
    chat_completion_function_url  = module.chat_completion.chat_completion_function_url
    region                        = var.region
    
    # Add these variables with values from your Amplify project
    cognito_user_pool_id       = "us-west-1_9ZbuQizvZ" # Replace with your actual Amplify-created User Pool ID
    cognito_user_pool_client_id = "30oarcfi7d6rseca2234957fm6" # Replace with your actual Amplify-created App Client ID
}


